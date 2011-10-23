BEGIN;

DROP TABLE IF EXISTS transports;

CREATE TABLE transports (
    id BIGINT NOT NULL AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    gateway_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    password TEXT,
    PRIMARY KEY (user_id, id),
    UNIQUE (user_id, gateway_id, name)
);

DROP FUNCTION IF EXISTS generate_metacontact;
DELIMITER //
CREATE FUNCTION generate_metacontact() RETURNS VARCHAR(255)
BEGIN
    RETURN CONCAT(UUID(), '@metacontact.rambler');
END //
DELIMITER ;

-- Список "реальных" метаконтактов
DROP TABLE IF EXISTS metacontacts;
CREATE TABLE metacontacts (
    user_id BIGINT NOT NULL,
    metacontact VARCHAR(255) NOT NULL,
    nickname TEXT,
    groups TEXT NOT NULL DEFAULT '',
    contacts_amount INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY (user_id, metacontact),
    CHECK (contacts_amount > 0)
);

DROP TRIGGER IF EXISTS trg__metacontacts__before_insert;
DELIMITER //
CREATE TRIGGER trg__metacontacts__before_insert BEFORE INSERT ON metacontacts FOR EACH ROW
BEGIN
    SET @amount = NULL;
    SELECT COUNT(*) FROM contacts WHERE user_id = NEW.user_id AND metacontact = NEW.metacontact INTO @amount;
    SET NEW.contacts_amount = @amount;
END //
DELIMITER ;

DROP TRIGGER IF EXISTS trg__metacontacts__before_update;
DELIMITER //
CREATE TRIGGER trg__metacontacts__before_update AFTER UPDATE ON metacontacts FOR EACH ROW
BEGIN
    IF NEW.contacts_amount = 0 THEN
        DELETE FROM metacontacts WHERE user_id = NEW.user_id AND metacontact = NEW.metacontact;
    END IF;
END //
DELIMITER ;

-- Список контактов пользователей
-- Поле status битовое: младшие три бита (0-2) отвечают за statusTo, следующие три бита (3-5) за statusFrom, бит 6 отвечает за бан контакта.
DROP TABLE IF EXISTS contacts;
CREATE TABLE contacts (
    id BIGINT NOT NULL AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    transport_id BIGINT NOT NULL DEFAULT 0,
    jid_name VARCHAR(700) NOT NULL,
    jid_domain VARCHAR(255) NOT NULL,
    status SMALLINT NOT NULL DEFAULT 0 CHECK (status < 128 AND status & 3 < 3 AND (status >> 2) & 3 < 3),
    nickname TEXT,
    groups TEXT NOT NULL DEFAULT '',
    metacontact TEXT NOT NULL DEFAULT '',
    PRIMARY KEY (user_id, id),
    UNIQUE (user_id, transport_id, jid_name, jid_domain),
    FOREIGN KEY (user_id, transport_id) REFERENCES roster.transports (user_id, id) ON DELETE CASCADE
);

DROP TABLE IF EXISTS deleted_contacts;
CREATE TABLE deleted_contacts (
    id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    transport_id BIGINT NOT NULL,
    jid_name VARCHAR(700) NOT NULL,
    jid_domain VARCHAR(255) NOT NULL,
    status SMALLINT NOT NULL DEFAULT 0 CHECK (status < 128 AND status & 3 < 3 AND (status >> 2) & 3 < 3),
    nickname TEXT,
    groups TEXT NOT NULL DEFAULT '',
    metacontact TEXT NOT NULL,
    dtime TIMESTAMP NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, id),
    UNIQUE (user_id, transport_id, jid_name, jid_domain)
);

CREATE INDEX ndx__deleted_contacts__dtime ON deleted_contacts (dtime);

DROP TRIGGER IF EXISTS trg__contacts__before_insert;
DELIMITER //
CREATE TRIGGER trg__contacts__before_insert BEFORE INSERT ON contacts FOR EACH ROW
BEGIN
    IF NEW.transport_id IS NULL OR NEW.transport_id = 0 THEN
        SET @transport_id = NULL;
        SELECT id FROM transports WHERE user_id = NEW.user_id AND gateway_id = 0 LIMIT 1 INTO @transport_id;
        IF @transport_id IS NULL THEN
            INSERT INTO transports (user_id, gateway_id, name) VALUES (NEW.user_id, 0, '');
            SET @transport_id = LAST_INSERT_ID();
        END IF;
        SET NEW.transport_id = @transport_id;
    END IF;
    IF NEW.metacontact IS NULL OR NEW.metacontact = '' THEN
        SET NEW.metacontact = generate_metacontact();
    END IF;
    UPDATE metacontacts
        SET contacts_amount = contacts_amount + 1
        WHERE user_id = NEW.user_id AND metacontact = NEW.metacontact;
    SET @id = NULL;
    SELECT id FROM deleted_contacts
        WHERE user_id = NEW.user_id AND transport_id = NEW.transport_id AND jid_name = NEW.jid_name AND jid_domain = NEW.jid_domain
        INTO @id;
    IF @id IS NOT NULL THEN
        DELETE FROM deleted_contacts
            WHERE user_id = NEW.user_id AND transport_id = NEW.transport_id AND jid_name = NEW.jid_name AND jid_domain = NEW.jid_domain;
        SET NEW.id = @id;
    END IF;
END //
DELIMITER ;

DROP TRIGGER IF EXISTS trg__contacts__before_update;
DELIMITER //
CREATE TRIGGER trg__contacts__before_update BEFORE UPDATE ON contacts FOR EACH ROW
BEGIN
    IF (NEW.metacontact IS NULL OR NEW.metacontact = '') THEN
        SET NEW.metacontact = generate_metacontact();
    END IF;
    IF (NEW.metacontact <> OLD.metacontact) THEN
        UPDATE metacontacts
            SET contacts_amount = contacts_amount + 1
            WHERE user_id = NEW.user_id AND metacontact = NEW.metacontact;
        UPDATE metacontacts
            SET contacts_amount = contacts_amount - 1
            WHERE user_id = OLD.user_id AND metacontact = OLD.metacontact;
    END IF;
END //
DELIMITER ;

DROP TRIGGER IF EXISTS trg__contacts__after_delete;
DELIMITER //
CREATE TRIGGER trg__contacts__after_delete AFTER DELETE ON contacts FOR EACH ROW
BEGIN
    SET @exists = NULL;
    SELECT COUNT(*) FROM deleted_contacts
        WHERE user_id = OLD.user_id AND transport_id = OLD.transport_id AND jid_name = OLD.jid_name AND jid_domain = OLD.jid_domain
        INTO @exists;
    IF @exists > 0 THEN
        UPDATE roster.deleted_contacts
            SET jid_name = CONCAT('Unrestorable (new id = ', OLD.id, '): ', jid_name)
            WHERE user_id = OLD.user_id AND transport_id = OLD.transport_id AND jid_name = OLD.jid_name AND jid_domain = OLD.jid_domain;
    END IF;
    INSERT INTO roster.deleted_contacts (id, user_id, transport_id, jid_name, jid_domain, status, nickname, groups, metacontact)
        VALUES (OLD.id, OLD.user_id, OLD.transport_id, OLD.jid_name, OLD.jid_domain, OLD.status, OLD.nickname, OLD.groups, OLD.metacontact);
    UPDATE roster.metacontacts
        SET contacts_amount = contacts_amount - 1
        WHERE user_id = OLD.user_id AND metacontact = OLD.metacontact;
END //
DELIMITER ;

COMMIT;