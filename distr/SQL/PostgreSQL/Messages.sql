BEGIN;

DROP SCHEMA IF EXISTS messages CASCADE;

CREATE SCHEMA messages;

CREATE SEQUENCE messages.offline_id_seq MINVALUE -32767 MAXVALUE 32767 CYCLE;

CREATE TABLE messages.offline (
    id SMALLINT NOT NULL DEFAULT nextval('messages.offline_id_seq'::regclass)::SMALLINT,
    user_id INTEGER NOT NULL,
    message XML NOT NULL,
    ctime TIMESTAMP WITH TIME ZONE NOT NULL,
    PRIMARY KEY (user_id, ctime, id)
);

CREATE TABLE messages.offline_presence_subscribe (
    user_id INTEGER NOT NULL,
    jid_name VARCHAR(1023) NOT NULL,
    jid_domain VARCHAR(255) NOT NULL,
    is_incoming BOOLEAN NOT NULL,
    message XML,
    ctime TIMESTAMP WITH TIME ZONE NOT NULL,
    PRIMARY KEY (user_id, jid_name, jid_domain, is_incoming)
);

CREATE FUNCTION messages.store_presence_subscribe_message(BIGINT, VARCHAR, VARCHAR, BOOLEAN, XML, TIMESTAMP) RETURNS VOID AS $_$
    DELETE FROM messages.offline_presence_subscribe WHERE user_id = $1 AND jid_name = $2 AND jid_domain = $3 AND is_incoming = $4;
    INSERT INTO messages.offline_presence_subscribe (user_id, jid_name, jid_domain, is_incoming, message, ctime) VALUES ($1, $2, $3, $4, $5, $6);
$_$ LANGUAGE SQL;

COMMIT;