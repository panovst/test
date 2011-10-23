BEGIN;

CREATE OR REPLACE FUNCTION history._trg__messages__after_delete() RETURNS TRIGGER AS $_$
BEGIN
    INSERT INTO history.deleted_messages (id, user_id, contact_id, collocutor, is_incoming, message, ctime, ctz)
        VALUES (OLD.id, OLD.user_id, OLD.contact_id, OLD.collocutor, OLD.is_incoming, OLD.message, OLD.ctime, OLD.ctz);
    RETURN OLD;
END;
$_$ LANGUAGE plpgsql;

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

DROP FUNCTION history.undelete(BIGINT, BIGINT, SMALLINT, TIMESTAMP WITH TIME ZONE, BIGINT);

ALTER TABLE history.messages DROP COLUMN "source";
ALTER TABLE history.deleted_messages DROP COLUMN "source";

ALTER TABLE history.messages ALTER COLUMN user_id SET DATA TYPE INTEGER;
ALTER TABLE history.deleted_messages ALTER COLUMN user_id SET DATA TYPE INTEGER;

ALTER SEQUENCE history.messages_id_seq MINVALUE -2147483647 MAXVALUE 2147483647 CYCLE;
ALTER TABLE history.messages ALTER COLUMN id SET DATA TYPE INTEGER USING id % 2147483648;
ALTER TABLE history.deleted_messages ALTER COLUMN id SET DATA TYPE INTEGER USING id % 2147483648;

COMMIT;