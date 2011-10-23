BEGIN;

CREATE TABLE xmpp.log_messages_databases (
    id SERIAL NOT NULL PRIMARY KEY,
    "database" VARCHAR(255) NOT NULL,
    "host" VARCHAR(255) NOT NULL,
    "port" SMALLINT NOT NULL DEFAULT 5432,
    "user" VARCHAR(255) NOT NULL,
    password VARCHAR(255),
    max_connections INTEGER,
    locked BOOLEAN NOT NULL DEFAULT false,
    fill_factor BIGINT NOT NULL DEFAULT 0 CHECK (fill_factor >= 0),
    UNIQUE ("database", "host", "user")
);

INSERT INTO xmpp.log_messages_databases ("database", "host", "port", "user", "password", max_connections)
    VALUES ('log', 'localhost', '5432', 'xmpp', 'xmpp', 20);

COMMIT;