BEGIN;

DROP SCHEMA IF EXISTS roster CASCADE;

CREATE SCHEMA roster;

CREATE TABLE roster.transports (
    id BIGSERIAL NOT NULL,
    user_id INTEGER NOT NULL,
    gateway_id BIGINT NOT NULL,
    name TEXT NOT NULL,
    password TEXT,
    hash_code TEXT,
    PRIMARY KEY (user_id, id),
    CONSTRAINT transports_primary_key UNIQUE (user_id, name),
    CONSTRAINT transports_native_check CHECK ((gateway_id = 0) = (name = ''))
);

CREATE UNIQUE INDEX ndx__transports__native ON roster.transports (user_id) WHERE gateway_id = 0;

CREATE SEQUENCE roster.contacts_metacontact_seq;

CREATE FUNCTION roster.contacts_metacontact(TEXT) RETURNS TEXT AS $_$
    SELECT
        CASE
            WHEN $1 IS NULL
                THEN EXTRACT(EPOCH FROM DATE_TRUNC('second', now()))::TEXT || '.' || NEXTVAL('roster.contacts_metacontact_seq')::TEXT || '@metacontact.rambler'
            ELSE $1
        END;
$_$ LANGUAGE SQL VOLATILE;

SELECT set_config('xmpp.roster_patch', 'false', false);

-- Список "реальных" метаконтактов
CREATE TABLE roster.metacontacts (
    user_id INTEGER NOT NULL,
    metacontact TEXT NOT NULL,
    nickname TEXT,
    groups TEXT[] NOT NULL DEFAULT '{}'::TEXT[],
    contacts_amount INTEGER NOT NULL,
    PRIMARY KEY (user_id, metacontact),
    CONSTRAINT metacontacts_contacts_amount_check CHECK (current_setting('xmpp.roster_patch')::BOOLEAN AND contacts_amount >= 0 OR contacts_amount > 0)
);

CREATE OR REPLACE FUNCTION roster._trg__metacontacts__before_insert() RETURNS TRIGGER AS $_$
BEGIN
    SELECT COUNT(*) INTO NEW.contacts_amount FROM roster.contacts WHERE user_id = NEW.user_id AND metacontact = NEW.metacontact;
    RETURN NEW;
END;
$_$ LANGUAGE plpgsql;

CREATE TRIGGER trg__metacontacts__before_insert BEFORE INSERT ON roster.metacontacts
    FOR EACH ROW EXECUTE PROCEDURE roster._trg__metacontacts__before_insert();

CREATE OR REPLACE FUNCTION roster._trg__metacontacts__before_update() RETURNS TRIGGER AS $_$
BEGIN
    IF (NOT(current_setting('xmpp.roster_patch')::BOOLEAN) AND NEW.contacts_amount = 0) THEN
        DELETE FROM roster.metacontacts WHERE user_id = NEW.user_id AND metacontact = NEW.metacontact;
        RETURN NULL;
    END IF;
    RETURN NEW;
END;
$_$ LANGUAGE plpgsql;

CREATE TRIGGER trg__metacontacts__before_update BEFORE UPDATE ON roster.metacontacts
    FOR EACH ROW EXECUTE PROCEDURE roster._trg__metacontacts__before_update();

-- Список контактов пользователей
-- Поле status битовое: младшие три бита (0-2) отвечают за statusTo, следующие три бита (3-5) за statusFrom, бит 6 отвечает за бан контакта.
CREATE TABLE roster.contacts (
    id BIGSERIAL NOT NULL,
    user_id INTEGER NOT NULL,
    transport_id BIGINT NOT NULL,
    jid_name VARCHAR(1023) NOT NULL,
    jid_domain VARCHAR(255) NOT NULL,
    status SMALLINT NOT NULL DEFAULT 0 CHECK (status < 128 AND status & 3 < 3 AND (status >> 2) & 3 < 3),
    nickname TEXT,
    groups TEXT[] NOT NULL DEFAULT '{}'::TEXT[],
    metacontact TEXT NOT NULL,
    enable_history BOOLEAN,
    CONSTRAINT contacts_primary_key PRIMARY KEY (user_id, jid_name, jid_domain),
    CONSTRAINT contacts_surrogate_key UNIQUE (user_id, id),
    CONSTRAINT contacts_transport_foreign_key FOREIGN KEY (user_id, transport_id) REFERENCES roster.transports (user_id, id) ON DELETE CASCADE
);

CREATE TABLE roster.deleted_contacts (
    id BIGINT NOT NULL,
    user_id INTEGER NOT NULL,
    transport_id BIGINT NOT NULL,
    jid_name VARCHAR(1023) NOT NULL,
    jid_domain VARCHAR(255) NOT NULL,
    status SMALLINT NOT NULL DEFAULT 0 CHECK (status < 128 AND status & 3 < 3 AND (status >> 2) & 3 < 3),
    nickname TEXT,
    groups TEXT[] NOT NULL DEFAULT '{}'::TEXT[],
    metacontact TEXT NOT NULL,
    dtime TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    enable_history BOOLEAN DEFAULT NULL,
    PRIMARY KEY (user_id, id),
    UNIQUE (user_id, transport_id, jid_name, jid_domain)
);

CREATE INDEX ndx__deleted_contacts__dtime ON roster.deleted_contacts (dtime);

CREATE OR REPLACE FUNCTION roster._trg__contacts__before_insert() RETURNS TRIGGER AS $_$
DECLARE contact roster.deleted_contacts%ROWTYPE;
BEGIN
    IF (NEW.transport_id IS NULL) THEN
        BEGIN
            SELECT id INTO STRICT NEW.transport_id FROM roster.transports WHERE user_id = NEW.user_id AND gateway_id = 0 LIMIT 1;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                INSERT INTO roster.transports (user_id, gateway_id, name) VALUES (NEW.user_id, 0, '') RETURNING id INTO STRICT NEW.transport_id;
        END;
    END IF;
    NEW.metacontact = roster.contacts_metacontact(NEW.metacontact);
    UPDATE roster.metacontacts
        SET contacts_amount = contacts_amount + 1
        WHERE user_id = NEW.user_id AND metacontact = NEW.metacontact;
    BEGIN
        DELETE FROM roster.deleted_contacts
            WHERE user_id = NEW.user_id AND transport_id = NEW.transport_id AND jid_name = NEW.jid_name AND jid_domain = NEW.jid_domain
            RETURNING * INTO STRICT contact;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NEW;
    END;
    NEW.id = contact.id;
    RETURN NEW;
END;
$_$ LANGUAGE plpgsql;

CREATE TRIGGER trg__contacts__before_insert BEFORE INSERT ON roster.contacts
    FOR EACH ROW EXECUTE PROCEDURE roster._trg__contacts__before_insert();

CREATE OR REPLACE FUNCTION roster._trg__contacts__before_update() RETURNS TRIGGER AS $_$
BEGIN
    NEW.metacontact = roster.contacts_metacontact(NEW.metacontact);
    IF (NEW.metacontact <> OLD.metacontact) THEN
        UPDATE roster.metacontacts
            SET contacts_amount = contacts_amount + 1
            WHERE user_id = NEW.user_id AND metacontact = NEW.metacontact;
        UPDATE roster.metacontacts
            SET contacts_amount = contacts_amount - 1
            WHERE user_id = OLD.user_id AND metacontact = OLD.metacontact;
    END IF;
    RETURN NEW;
END;
$_$ LANGUAGE plpgsql;

CREATE TRIGGER trg__contacts__before_update BEFORE UPDATE ON roster.contacts
    FOR EACH ROW EXECUTE PROCEDURE roster._trg__contacts__before_update();

CREATE OR REPLACE FUNCTION roster._trg__contacts__after_delete() RETURNS TRIGGER AS $_$
DECLARE contact roster.deleted_contacts%ROWTYPE;
BEGIN
    BEGIN
        INSERT INTO roster.deleted_contacts (id, user_id, transport_id, jid_name, jid_domain, status, nickname, groups, metacontact)
            VALUES (OLD.id, OLD.user_id, OLD.transport_id, OLD.jid_name, OLD.jid_domain, OLD.status, OLD.nickname, OLD.groups, OLD.metacontact);
    EXCEPTION
        WHEN UNIQUE_VIOLATION THEN
            UPDATE roster.deleted_contacts
                SET jid_name = 'Unrestorable (new id = ' || OLD.id || '): ' || jid_name
                WHERE user_id = OLD.user_id AND transport_id = OLD.transport_id AND jid_name = OLD.jid_name AND jid_domain = OLD.jid_domain
                RETURNING * INTO STRICT contact;
            INSERT INTO roster.deleted_contacts (id, user_id, transport_id, jid_name, jid_domain, status, nickname, groups, metacontact)
                VALUES (OLD.id, OLD.user_id, OLD.transport_id, OLD.jid_name, OLD.jid_domain, OLD.status, OLD.nickname, OLD.groups, OLD.metacontact);
            RAISE NOTICE 'Contact (id = %, new id = %) is unrestorable', contact.id, OLD.id;
    END;
    UPDATE roster.metacontacts
        SET contacts_amount = contacts_amount - 1
        WHERE user_id = OLD.user_id AND metacontact = OLD.metacontact;
    RETURN OLD;
END;
$_$ LANGUAGE plpgsql;

CREATE TRIGGER trg__contacts__after_delete AFTER DELETE ON roster.contacts
    FOR EACH ROW EXECUTE PROCEDURE roster._trg__contacts__after_delete();

CREATE TABLE roster.cache (
    user_id INTEGER NOT NULL PRIMARY KEY,
    ctime TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    roster BYTEA NOT NULL
);

CREATE OR REPLACE FUNCTION roster.cache(INTEGER, BYTEA) RETURNS BOOLEAN AS $_$
DECLARE _user_id ALIAS FOR $1;
        _roster ALIAS FOR $2;
BEGIN
    UPDATE roster.cache SET roster = _roster WHERE user_id = _user_id;
    IF NOT FOUND THEN
        BEGIN
            INSERT INTO roster.cache (user_id, roster)
                VALUES (_user_id, _roster);
        EXCEPTION
            WHEN UNIQUE_VIOLATION THEN
                DELETE FROM roster.cache
                    WHERE user_id = _user_id;
                RAISE NOTICE 'Roster cache unique violation: user_id = %', _user_id;
        END;
        RETURN FALSE;
    END IF;
    RETURN TRUE;
END;
$_$ LANGUAGE plpgsql;

COMMIT;