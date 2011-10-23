BEGIN;

ALTER TABLE roster.transports ALTER COLUMN user_id SET DATA TYPE INTEGER;
ALTER TABLE roster.metacontacts ALTER COLUMN user_id SET DATA TYPE INTEGER;
ALTER TABLE roster.contacts ALTER COLUMN user_id SET DATA TYPE INTEGER;
ALTER TABLE roster.deleted_contacts ALTER COLUMN user_id SET DATA TYPE INTEGER;
ALTER TABLE roster.cache ALTER COLUMN user_id SET DATA TYPE INTEGER;

CREATE FUNCTION roster.cache(INTEGER, BYTEA) RETURNS BOOLEAN AS $_$
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
DROP FUNCTION roster.cache(BIGINT, BYTEA);

COMMIT;