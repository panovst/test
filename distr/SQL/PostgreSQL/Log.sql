BEGIN;

DROP SCHEMA IF EXISTS log CASCADE;

CREATE SCHEMA log;

CREATE TABLE log.message_actors (
    id SMALLINT UNIQUE,
    name VARCHAR(64) PRIMARY KEY
);

INSERT INTO log.message_actors (id, name) values
    (1, 'client'),
    (2, 'component');

CREATE TABLE log.messages (
    jid_node VARCHAR(512) NOT NULL,
    jid_domain VARCHAR(256) NOT NULL,
    jid_resource VARCHAR(1023) NOT NULL,
    actor SMALLINT NOT NULL REFERENCES log.message_actors (id),
    actor_jid TEXT NOT NULL,
    session TEXT NOT NULL,
    "time" TIMESTAMP WITH TIME ZONE NOT NULL,
    tz SMALLINT NOT NULL,
    roster_version TEXT,
    is_incoming BOOLEAN NOT NULL,
    content TEXT
);

CREATE INDEX ndx_messages_main ON log.messages (jid_node, jid_domain, "time");
CREATE INDEX ndx_messages_time ON log.messages ("time");

COMMIT;