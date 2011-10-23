BEGIN;

ALTER SEQUENCE xmpp.users_id_seq MAXVALUE 2147483647 NO CYCLE;
ALTER TABLE xmpp.users ALTER COLUMN id SET DATA TYPE INTEGER;

ALTER TABLE xmpp.user_passwords ALTER COLUMN user_id SET DATA TYPE INTEGER;

CREATE FUNCTION xmpp.set_user_password(INTEGER, TEXT) RETURNS VOID AS $_$
DECLARE _user_id ALIAS FOR $1;
        _password ALIAS FOR $2;
        _encoded_password TEXT;
BEGIN
    _encoded_password := encode(digest(_password, 'sha512'), 'base64');
    UPDATE xmpp.user_passwords SET password = _encoded_password WHERE user_id = _user_id;
    IF NOT FOUND THEN
        INSERT INTO xmpp.user_passwords (user_id, password) VALUES (_user_id, _encoded_password);
    END IF;
END;
$_$ LANGUAGE plpgsql;
DROP FUNCTION xmpp.set_user_password(BIGINT, TEXT);

CREATE FUNCTION xmpp.check_user_password(INTEGER, TEXT) RETURNS BOOLEAN AS $_$
DECLARE _user_id ALIAS FOR $1;
        _password ALIAS FOR $2;
        _encoded_password TEXT;
        _result BOOLEAN := NULL;
BEGIN
    _encoded_password := encode(digest(_password, 'sha512'), 'base64');
    SELECT INTO _result password = _encoded_password FROM xmpp.user_passwords WHERE user_id = _user_id;
    return _result;
END;
$_$ LANGUAGE plpgsql;
DROP FUNCTION xmpp.check_user_password(BIGINT, TEXT);

ALTER TABLE xmpp.users_messages_archives ALTER COLUMN user_id SET DATA TYPE INTEGER;
ALTER TABLE xmpp.users_deleted_archives ALTER COLUMN user_id SET DATA TYPE INTEGER;
ALTER TABLE xmpp.deleted_users ALTER COLUMN id SET DATA TYPE INTEGER;

COMMIT;