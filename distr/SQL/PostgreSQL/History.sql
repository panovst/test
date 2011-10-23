BEGIN;

DROP SCHEMA IF EXISTS history CASCADE;
CREATE SCHEMA history;

CREATE TABLE history.messages (
    id SERIAL NOT NULL,
    user_id INTEGER NOT NULL,
    contact_id BIGINT NOT NULL,
    collocutor TEXT NOT NULL,
    is_incoming BOOLEAN NOT NULL,
    message XML NOT NULL,
    ctime TIMESTAMP WITH TIME ZONE NOT NULL,
    ctz SMALLINT NOT NULL,
    PRIMARY KEY (user_id, contact_id, ctime, id)
);

CREATE TABLE history.deleted_messages (
    id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    contact_id BIGINT NOT NULL,
    collocutor TEXT NOT NULL,
    is_incoming BOOLEAN NOT NULL,
    message XML NOT NULL,
    ctime TIMESTAMP WITH TIME ZONE NOT NULL,
    ctz SMALLINT NOT NULL,
    dtime TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, contact_id, ctime, id)
);

CREATE INDEX ndx__deleted_messages__dtime ON history.deleted_messages (dtime);

CREATE FUNCTION history._trg__messages__after_delete() RETURNS TRIGGER AS $_$
BEGIN
    INSERT INTO history.deleted_messages (id, user_id, contact_id, collocutor, is_incoming, message, ctime, ctz)
        VALUES (OLD.id, OLD.user_id, OLD.contact_id, OLD.collocutor, OLD.is_incoming, OLD.message, OLD.ctime, OLD.ctz);
    RETURN OLD;
END;
$_$ LANGUAGE plpgsql;

CREATE TRIGGER trg__messages__after_delete AFTER DELETE ON history.messages
    FOR EACH ROW EXECUTE PROCEDURE history._trg__messages__after_delete();

CREATE FUNCTION history.undelete(INTEGER, BIGINT, TIMESTAMP WITH TIME ZONE, INTEGER) RETURNS SETOF history.messages AS $_$
DECLARE _message history.messages%ROWTYPE;
BEGIN
    BEGIN
        INSERT INTO history.messages (id, user_id, contact_id, collocutor, is_incoming, message, ctime, ctz)
            SELECT id, user_id, contact_id, collocutor, is_incoming, message, ctime, ctz
                FROM history.deleted_messages
                WHERE user_id = $1 AND contact_id = $2 AND ctime = $3 AND id = $4
            RETURNING * INTO STRICT _message;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN;
    END;
    DELETE FROM history.deleted_messages
        WHERE user_id = $1 AND contact_id = $2 AND ctime = $3 AND id = $4;
    RETURN NEXT _message;
END;
$_$ LANGUAGE plpgsql;

COMMIT;