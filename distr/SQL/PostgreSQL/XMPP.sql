BEGIN;

DROP SCHEMA IF EXISTS xmpp CASCADE;

CREATE SCHEMA xmpp;

-- Наши домены. :)
CREATE TABLE xmpp.domains (
    id SERIAL NOT NULL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    configuration TEXT,
    undeletable BOOLEAN NOT NULL DEFAULT false,
    users_amount BIGINT NOT NULL DEFAULT 0
);

INSERT INTO xmpp.domains (name, undeletable) VALUES ('rambler.ru', true);
INSERT INTO xmpp.domains (name, undeletable) VALUES ('lenta.ru', true);
INSERT INTO xmpp.domains (name, undeletable) VALUES ('myrambler.ru', true);
INSERT INTO xmpp.domains (name, undeletable) VALUES ('autorambler.ru', true);
INSERT INTO xmpp.domains (name, undeletable) VALUES ('ro.ru', true);
INSERT INTO xmpp.domains (name, undeletable) VALUES ('r0.ru', true);
INSERT INTO xmpp.domains (name, undeletable) VALUES ('federation.rambler.ru', true);
INSERT INTO xmpp.domains (name, undeletable) VALUES ('anonymous.rambler.ru', true);
INSERT INTO xmpp.domains (name, undeletable) VALUES ('localhost', true);
INSERT INTO xmpp.domains (name, undeletable) VALUES ('127.0.0.1', true);
INSERT INTO xmpp.domains (name, undeletable) VALUES ('jabber.dev.rambler.ru', true);

CREATE FUNCTION xmpp._trg__domains__before_delete() RETURNS TRIGGER AS $_$
BEGIN
    IF OLD.undeletable THEN
        RAISE EXCEPTION 'Domain % is undeletable', OLD.name USING ERRCODE = 'modifying_sql_data_not_permitted';
    END IF;
    RETURN OLD;
END;
$_$ LANGUAGE plpgsql;

CREATE TRIGGER trg__domains__before_delete BEFORE DELETE ON xmpp.domains
    FOR EACH ROW EXECUTE PROCEDURE xmpp._trg__domains__before_delete();

-- Домены компонентов    
CREATE TABLE xmpp.component_domain (
	name VARCHAR(256) NOT NULL PRIMARY KEY
);

-- Транспорты
CREATE TABLE xmpp.gateways (
    id BIGINT NOT NULL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    data TEXT
);

INSERT INTO xmpp.gateways (id, name)
    VALUES (0, 'native'),
           (1, 'aim'),
           (2, 'facebook'),
           (3, 'gadu-gadu'),
           (4, 'http-ws'),
           (5, 'icq'),
           (6, 'irc'),
           (7, 'ics'),
           (8, 'mrim'),
           (9, 'msn'),
           (10, 'myspaceim'),
           (11, 'ocs'),
           (12, 'qq'),
           (13, 'sametime'),
           (14, 'simple'),
           (15, 'skype'),
           (16, 'sms'),
           (17, 'smtp'),
           (18, 'tlen'),
           (19, 'xfire'),
           (20, 'xmpp'),
           (21, 'yahoo'),
           (22, 'mail');


-- Базы данных для историй сообщений контактов
CREATE TABLE xmpp.history_databases (
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

INSERT INTO xmpp.history_databases ("database", "host", "port", "user", "password", max_connections)
    VALUES ('history1', 'localhost', '5432', 'xmpp', 'xmpp', 20);

INSERT INTO xmpp.history_databases ("database", "host", "port", "user", "password", max_connections)
    VALUES ('history2', 'localhost', '5432', 'xmpp', 'xmpp', 20);

CREATE INDEX ndx__history_databases__fill_factor ON xmpp.history_databases (fill_factor) WHERE NOT locked;

-- Базы данных для хранения контактов
CREATE TABLE xmpp.roster_databases (
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

INSERT INTO xmpp.roster_databases ("database", "host", "port", "user", "password", max_connections)
    VALUES ('roster1', 'localhost', '5432', 'xmpp', 'xmpp', 20);

INSERT INTO xmpp.roster_databases ("database", "host", "port", "user", "password", max_connections)
    VALUES ('roster2', 'localhost', '5432', 'xmpp', 'xmpp', 20);

CREATE INDEX ndx__roster_databases__fill_factor ON xmpp.roster_databases (fill_factor) WHERE NOT locked;

-- Базы данных для хранения сообщений (в частности, оффлайн)
CREATE TABLE xmpp.messages_databases (
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

INSERT INTO xmpp.messages_databases ("database", "host", "port", "user", "password", max_connections)
    VALUES ('messages', 'localhost', '5432', 'xmpp', 'xmpp', 20);

CREATE INDEX ndx__messages_databases__fill_factor ON xmpp.messages_databases (fill_factor) WHERE NOT locked;

-- Базы логов
CREATE TABLE xmpp.log_messages_databases (
    id SERIAL NOT NULL PRIMARY KEY,
    "database" VARCHAR(255) NOT NULL,
    "host" VARCHAR(255) NOT NULL,
    "port" SMALLINT NOT NULL DEFAULT 5432,
    "user" VARCHAR(255) NOT NULL,
    password VARCHAR(255),
    max_connections INTEGER,
    locked BOOLEAN NOT NULL DEFAULT false,
    UNIQUE ("database", "host", "user")
);

INSERT INTO xmpp.log_messages_databases ("database", "host", "port", "user", "password", max_connections)
    VALUES ('log', 'localhost', '5432', 'xmpp', 'xmpp', 20);

-- Пользователи.
CREATE TABLE xmpp.users (
    id SERIAL NOT NULL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    domain_id INTEGER NOT NULL REFERENCES xmpp.domains (id),
    vcard XML,
    "options" XML,
    ctime TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    mtime TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    history_database_id INTEGER NOT NULL REFERENCES xmpp.history_databases (id),
    history_database_start_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT '-infinity'::TIMESTAMP WITH tIME ZONE,
    roster_database_id INTEGER NOT NULL REFERENCES xmpp.roster_databases (id),
    messages_database_id INTEGER NOT NULL REFERENCES xmpp.messages_databases (id),
    enable_history BOOLEAN NOT NULL DEFAULT true,
    history_save_default BOOLEAN NOT NULL DEFAULT true,
    log_until TIMESTAMP WITH TIME ZONE DEFAULT null,
    UNIQUE (name, domain_id)
);

-- Пароли пользователей - доступ должен осуществляться строго через хранимые процедуры.
-- Пароль хранится в виде дайджеста Base64 над алгоритмом sha512
CREATE TABLE xmpp.user_passwords (
    user_id INTEGER NOT NULL PRIMARY KEY REFERENCES xmpp.users(id) ON DELETE CASCADE,
    password TEXT
);

-- Установка нового пароля пользователя.
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

-- Проверка пароля пользователя.
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

-- Базы архивов сообщений (практически read only для пользователей)
CREATE TABLE xmpp.users_messages_archives (
    user_id INTEGER NOT NULL REFERENCES xmpp.users (id) ON DELETE CASCADE,
    database_id INTEGER NOT NULL REFERENCES xmpp.history_databases (id),
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    CHECK (start_time < end_time),
    PRIMARY KEY (user_id, start_time, end_time)
);

-- Удаленные архивы для последующей очистки
CREATE TABLE xmpp.users_deleted_archives (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    database_id INTEGER REFERENCES xmpp.history_databases (id),
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    CHECK (start_time < end_time)
);

CREATE INDEX ndx__users_deleted_archives__user_id__database_id ON xmpp.users_deleted_archives (user_id, database_id);

-- Удаленные пользователи
CREATE TABLE xmpp.deleted_users (
    id INTEGER NOT NULL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    domain_id INTEGER NOT NULL REFERENCES xmpp.domains (id),
    vcard XML,
    "options" XML,
    ctime TIMESTAMP WITH TIME ZONE NOT NULL,
    mtime TIMESTAMP WITH TIME ZONE NOT NULL,
    dtime TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    -- При установке данного поля необходимо также устанавливать history_database_start_time,
    -- причем новое значение должно быть больше предыдущего.
    history_database_id INTEGER NOT NULL REFERENCES xmpp.history_databases (id),
    history_database_start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    roster_database_id INTEGER NOT NULL REFERENCES xmpp.roster_databases (id),
    messages_database_id INTEGER NOT NULL REFERENCES xmpp.messages_databases (id)
);

CREATE INDEX ndx__deleted_users__dtime ON xmpp.deleted_users (dtime);

-- Перед вставкой заполняем поля
CREATE FUNCTION xmpp._trg__users__before_insert() RETURNS TRIGGER AS $_$
BEGIN
    NEW.ctime = now();
    NEW.mtime = now();
    IF (NEW.history_database_id IS NULL) THEN
        SELECT INTO NEW.history_database_id id FROM xmpp.history_databases WHERE NOT locked ORDER BY fill_factor LIMIT 1;
    END IF;
    NEW.history_database_start_time = '-infinity'::TIMESTAMP WITH TIME ZONE;
    UPDATE xmpp.history_databases SET fill_factor = fill_factor + 1 WHERE id = NEW.history_database_id;
    IF (NEW.roster_database_id IS NULL) THEN
        SELECT INTO NEW.roster_database_id id FROM xmpp.roster_databases WHERE NOT locked ORDER BY fill_factor LIMIT 1;
    END IF;
    UPDATE xmpp.roster_databases SET fill_factor = fill_factor + 1 WHERE id = NEW.roster_database_id;
    IF (NEW.messages_database_id IS NULL) THEN
        SELECT INTO NEW.messages_database_id id FROM xmpp.messages_databases WHERE NOT locked ORDER BY fill_factor LIMIT 1;
    END IF;
    UPDATE xmpp.messages_databases SET fill_factor = fill_factor + 1 WHERE id = NEW.messages_database_id;
    UPDATE xmpp.domains SET users_amount = users_amount + 1 WHERE id = NEW.domain_id;
    RETURN NEW;
END;
$_$ LANGUAGE plpgsql;

CREATE TRIGGER trg__users__before_insert BEFORE INSERT ON xmpp.users
    FOR EACH ROW EXECUTE PROCEDURE xmpp._trg__users__before_insert();

-- При изменении текущей базы истории пользователя предыдущая база уходит в архив.
-- Если база была инициализирована хоть раз, сбрасывать значение history_database_id в NULL уже нельзя.
CREATE FUNCTION xmpp._trg__users__before_update() RETURNS TRIGGER AS $_$
BEGIN
    NEW.mtime = now();
    IF (OLD.history_database_id <> NEW.history_database_id) THEN
        INSERT INTO xmpp.users_messages_archives (user_id, database_id, start_time, end_time)
            VALUES (OLD.id, OLD.history_database_id, OLD.history_database_start_time, NEW.history_database_start_time);
        UPDATE xmpp.history_databases SET fill_factor = fill_factor + 1 WHERE id = NEW.history_database_id;
    ELSE
        NEW.history_database_start_time = OLD.history_database_start_time;
    END IF;
    IF (OLD.roster_database_id <> NEW.roster_database_id) THEN
        UPDATE xmpp.roster_databases SET fill_factor = fill_factor - 1 WHERE id = OLD.roster_database_id;
        UPDATE xmpp.roster_databases SET fill_factor = fill_factor + 1 WHERE id = NEW.roster_database_id;
    END IF;
    IF (OLD.messages_database_id <> NEW.messages_database_id) THEN
        UPDATE xmpp.messages_databases SET fill_factor = fill_factor - 1 WHERE id = OLD.messages_database_id;
        UPDATE xmpp.messages_databases SET fill_factor = fill_factor + 1 WHERE id = NEW.messages_database_id;
    END IF;
    IF (OLD.domain_id <> NEW.domain_id) THEN
        UPDATE xmpp.domains SET users_amount = users_amount - 1 WHERE id = OLD.domain_id;
        UPDATE xmpp.domains SET users_amount = users_amount + 1 WHERE id = NEW.domain_id;
    END IF;
    RETURN NEW;
END;
$_$ LANGUAGE plpgsql;

CREATE TRIGGER trg__users__before_update BEFORE UPDATE ON xmpp.users
    FOR EACH ROW EXECUTE PROCEDURE xmpp._trg__users__before_update();

-- При окончательном удалении пользователя текущая база истории ставится в очередь на очистку.
CREATE FUNCTION xmpp._trg__users__before_delete() RETURNS TRIGGER AS $_$
BEGIN
    INSERT INTO xmpp.users_deleted_archives (user_id, database_id, start_time, end_time)
        VALUES (OLD.id, OLD.history_database_id, OLD.history_database_start_time, 'infinity');
    INSERT INTO xmpp.deleted_users (id, "name", domain_id, vcard, "options", ctime, mtime,
                                    history_database_id, history_database_start_time, roster_database_id, messages_database_id)
        VALUES (OLD.id, OLD."name", OLD.domain_id, OLD.vcard, OLD."options", OLD.ctime, OLD.mtime,
                OLD.history_database_id, OLD.history_database_start_time, OLD.roster_database_id, OLD.messages_database_id);
    UPDATE xmpp.domains SET users_amount = users_amount - 1 WHERE id = OLD.domain_id;
    RETURN OLD;
END;
$_$ LANGUAGE plpgsql;

CREATE TRIGGER trg__users__before_delete BEFORE DELETE ON xmpp.users
    FOR EACH ROW EXECUTE PROCEDURE xmpp._trg__users__before_delete();

-- При удалении ахивной базы она ставится в очередь на очистку
CREATE FUNCTION xmpp._trg__users_messages_archives__before_delete() RETURNS TRIGGER AS $_$
BEGIN
    INSERT INTO xmpp.users_deleted_archives (user_id, database_id, start_time, end_time)
        VALUES (OLD.user_id, OLD.database_id, OLD.start_time, OLD.end_time);
    RETURN OLD;
END;
$_$ LANGUAGE plpgsql;

CREATE TRIGGER trg__users_messages_archives__before_delete BEFORE DELETE ON xmpp.users_messages_archives
    FOR EACH ROW EXECUTE PROCEDURE xmpp._trg__users_messages_archives__before_delete();

-- Новостной бот
INSERT INTO xmpp.users (name, domain_id)
    SELECT 'newsbot', id FROM xmpp.domains WHERE name = 'rambler.ru';
SELECT xmpp.set_user_password(currval('users_id_seq')::INTEGER, 'ax3dkf4l_s4hhmds');

-- Вставка тестовых пользователей
INSERT INTO xmpp.users (name, domain_id)
    SELECT 'testuser', id FROM xmpp.domains WHERE name = 'rambler.ru';
SELECT xmpp.set_user_password(currval('users_id_seq')::INTEGER, 'testpassword');
INSERT INTO xmpp.users (name, domain_id)
    SELECT 'testuser', id FROM xmpp.domains WHERE name = 'federation.rambler.ru';
SELECT xmpp.set_user_password(currval('users_id_seq')::INTEGER, 'testpassword');

INSERT INTO xmpp.users (name, domain_id)
    SELECT 'usertest', id FROM xmpp.domains WHERE name = 'rambler.ru';
SELECT xmpp.set_user_password(currval('users_id_seq')::INTEGER, 'passwordtest');

-- Пользователи для нагрузочного тестирования
INSERT INTO xmpp.users (name, domain_id)
    SELECT 'test_201', id FROM xmpp.domains WHERE name = 'localhost';
SELECT xmpp.set_user_password(currval('users_id_seq')::INTEGER, 'password');

INSERT INTO xmpp.users (name, domain_id)
    SELECT 'test_202', id FROM xmpp.domains WHERE name = 'localhost';
SELECT xmpp.set_user_password(currval('users_id_seq')::INTEGER, 'password');

INSERT INTO xmpp.users (name, domain_id)
    SELECT 'test_0', id FROM xmpp.domains WHERE name = 'localhost';
SELECT xmpp.set_user_password(currval('users_id_seq')::INTEGER, 'password');

INSERT INTO xmpp.users (name, domain_id)
    SELECT 'test_0', id FROM xmpp.domains WHERE name = 'rambler.ru';
SELECT xmpp.set_user_password(currval('users_id_seq')::INTEGER, 'password');

INSERT INTO xmpp.users (name, domain_id)
    SELECT 'test_1', id FROM xmpp.domains WHERE name = 'localhost';
SELECT xmpp.set_user_password(currval('users_id_seq')::INTEGER, 'password');

INSERT INTO xmpp.users (name, domain_id)
    SELECT 'test_1', id FROM xmpp.domains WHERE name = 'rambler.ru';
SELECT xmpp.set_user_password(currval('users_id_seq')::INTEGER, 'password');

-- Специальный пользователь для тестирования без фикстур SetupUsers
INSERT INTO xmpp.users (name, domain_id)
    SELECT 'test_osgi', id FROM xmpp.domains WHERE name = 'localhost';
SELECT xmpp.set_user_password(currval('users_id_seq')::INTEGER, 'password');

COMMIT;
