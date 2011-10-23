BEGIN;

DROP SCHEMA IF EXISTS configuration CASCADE;

CREATE SCHEMA configuration;

-- Список существующих в базе pid'ов. Прежде, чем добавлять свойства сервисов, необходимо внести pid сервиса в эту таблицу.
CREATE TABLE configuration.pids (
    pid VARCHAR(255) NOT NULL PRIMARY KEY
);

INSERT INTO configuration.pids (pid) VALUES ('ru.rambler.xmpp.server.core.log.impl.MongoLogMessageServiceImpl');
INSERT INTO configuration.pids (pid) VALUES ('ru.rambler.xmpp.server.core.dao.impl.PgConnectionService');
INSERT INTO configuration.pids (pid) VALUES ('ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl');
INSERT INTO configuration.pids (pid) VALUES ('ru.rambler.xmpp.server.core.domain.impl.PgDomainService');
INSERT INTO configuration.pids (pid) VALUES ('ru.rambler.xmpp.server.core.user.impl.PgUserService');
INSERT INTO configuration.pids (pid) VALUES ('ru.rambler.xmpp.server.core.user.impl.cache.LocalUserCacheService');
INSERT INTO configuration.pids (pid) VALUES ('ru.rambler.xmpp.server.core.user.impl.cache.LocalContactsCacheService');
INSERT INTO configuration.pids (pid) VALUES ('ru.rambler.xmpp.server.core.user.impl.cache.LocalUserObjectCacheService');
INSERT INTO configuration.pids (pid) VALUES ('ru.rambler.xmpp.server.core.message.impl.PgOfflineMessageService');
INSERT INTO configuration.pids (pid) VALUES ('ru.rambler.xmpp.server.core.history.impl.PgHistoryService');
INSERT INTO configuration.pids (pid) VALUES ('ru.rambler.xmpp.server.core.log.impl.PgLogMessageService');
INSERT INTO configuration.pids (pid) VALUES ('ru.rambler.xmpp.server.janitor.impl.PgJanitor');
INSERT INTO configuration.pids (pid) VALUES ('ru.rambler.xmpp.server.core.cluster.impl.ClusterServiceImpl');
INSERT INTO configuration.pids (pid) VALUES ('ru.rambler.xmpp.server.core.net.nio.ConnectionManagerServiceImpl');
INSERT INTO configuration.pids (pid) VALUES ('ru.rambler.xmpp.server.jms.impl.amq.AMQService');
INSERT INTO configuration.pids (pid) VALUES ('ru.rambler.api.impl.RamblerApiServiceImpl');



-- Дерево свойств. parent_id описывает свойство-предок.
-- Допустимо несколько свойств с одним и тем же именем в одной ветке, в этом случае доступ осуцествляется через итератор.
CREATE TABLE configuration.properties (
    id BIGSERIAL NOT NULL,
    pid VARCHAR(255) NOT NULL REFERENCES configuration.pids (pid) ON DELETE CASCADE ON UPDATE CASCADE,
    parent_id BIGINT DEFAULT NULL,
    name VARCHAR(255) NOT NULL,
    value TEXT
);

-- Сервис персонального логирования --
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.core.log.impl.MongoLogMessageServiceImpl', 'host', 'localhost');
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.core.log.impl.MongoLogMessageServiceImpl', 'port', '27017');
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.core.log.impl.MongoLogMessageServiceImpl', 'dbName', 'logging');
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.core.log.impl.MongoLogMessageServiceImpl', 'collectioName', 'osgiTestCollection');
    
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.core.dao.impl.PgConnectionService', 'host', 'localhost');
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.core.dao.impl.PgConnectionService', 'database', 'xmpp');
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.core.dao.impl.PgConnectionService', 'port', '5432');
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.core.dao.impl.PgConnectionService', 'user', 'xmpp');
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.core.dao.impl.PgConnectionService', 'password', 'xmpp');
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.core.dao.impl.PgConnectionService', 'max_connections', '20');

INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.core.domain.impl.PgDomainService', 'base_domain', 'rambler.ru');

INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.core.user.impl.PgUserService', 'producer_pool_size', '16');
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.core.user.impl.PgUserService', 'deleted_user_lifetime', '1 month');
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.core.user.impl.PgUserService', 'deleted_contact_lifetime', '1 month');
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.core.user.impl.PgUserService', 'deleted_contact_chunk_size', '4096');

INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.core.user.impl.cache.LocalUserCacheService', 'limit', 1::BIGINT * 1024 * 1024);
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.core.user.impl.cache.LocalContactsCacheService', 'limit', 3::BIGINT * 1024 * 1024);
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.core.user.impl.cache.LocalUserObjectCacheService', 'limit', 16 * 1024);

INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.core.message.impl.PgOfflineMessageService', 'queue_timeout', '10');
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.core.message.impl.PgOfflineMessageService', 'messages_bulk_size', '4000');
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.core.message.impl.PgOfflineMessageService', 'max_amount', '100');

INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.core.history.impl.PgHistoryService', 'queue_timeout', '10');
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.core.history.impl.PgHistoryService', 'messages_bulk_size', '4000');
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.core.history.impl.PgHistoryService', 'deleted_item_lifetime', '1 day');

INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.core.log.impl.PgLogMessageService', 'queue_timeout', '10');
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.core.log.impl.PgLogMessageService', 'messages_bulk_size', '4000');

INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl', 'domains', '');

INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl', id, 'rambler.ru', ''
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl' AND name = 'domains' AND
              parent_id IS NULL;
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl', id, 'mechs', 'PLAIN'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl' AND name = 'rambler.ru' AND
              parent_id IN (
                  SELECT id
                      FROM configuration.properties
                      WHERE pid = 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl' AND name = 'domains' AND
                            parent_id IS NULL
              );

INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl', id, 'lenta.ru', ''
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl' AND name = 'domains' AND
              parent_id IS NULL;
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl', id, 'mechs', 'PLAIN'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl' AND name = 'lenta.ru' AND
              parent_id IN (
                  SELECT id
                      FROM configuration.properties
                      WHERE pid = 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl' AND name = 'domains' AND
                            parent_id IS NULL
              );
              
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl', id, 'myrambler.ru', ''
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl' AND name = 'domains' AND
              parent_id IS NULL;
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl', id, 'mechs', 'PLAIN'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl' AND name = 'myrambler.ru' AND
              parent_id IN (
                  SELECT id
                      FROM configuration.properties
                      WHERE pid = 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl' AND name = 'domains' AND
                            parent_id IS NULL
              );

INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl', id, 'autorambler.ru', ''
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl' AND name = 'domains' AND
              parent_id IS NULL;
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl', id, 'mechs', 'PLAIN'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl' AND name = 'autorambler.ru' AND
              parent_id IN (
                  SELECT id
                      FROM configuration.properties
                      WHERE pid = 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl' AND name = 'domains' AND
                            parent_id IS NULL
              );
              
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl', id, 'ro.ru', ''
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl' AND name = 'domains' AND
              parent_id IS NULL;
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl', id, 'mechs', 'PLAIN'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl' AND name = 'ro.ru' AND
              parent_id IN (
                  SELECT id
                      FROM configuration.properties
                      WHERE pid = 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl' AND name = 'domains' AND
                            parent_id IS NULL
              );

INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl', id, 'r0.ru', ''
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl' AND name = 'domains' AND
              parent_id IS NULL;
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl', id, 'mechs', 'PLAIN'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl' AND name = 'r0.ru' AND
              parent_id IN (
                  SELECT id
                      FROM configuration.properties
                      WHERE pid = 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl' AND name = 'domains' AND
                            parent_id IS NULL
              );
              
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl', id, 'federation.rambler.ru', ''
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl' AND name = 'domains' AND
              parent_id IS NULL;
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl', id, 'mechs', 'PLAIN'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl' AND name = 'federation.rambler.ru' AND
              parent_id IN (
                  SELECT id
                      FROM configuration.properties
                      WHERE pid = 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl' AND name = 'domains' AND
                            parent_id IS NULL
              );

INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl', id, 'anonymous.rambler.ru', ''
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl' AND name = 'domains' AND
              parent_id IS NULL;
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl', id, 'mechs', 'ANONYMOUS'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl' AND name = 'anonymous.rambler.ru' AND
              parent_id IN (
                  SELECT id
                      FROM configuration.properties
                      WHERE pid = 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl' AND name = 'domains' AND
                            parent_id IS NULL
              );
              
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl', id, 'localhost', ''
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl' AND name = 'domains' AND
              parent_id IS NULL;
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl', id, 'mechs', 'PLAIN'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl' AND name = 'localhost' AND
              parent_id IN (
                  SELECT id
                      FROM configuration.properties
                      WHERE pid = 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl' AND name = 'domains' AND
                            parent_id IS NULL
              );

INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl', id, '127.0.0.1', ''
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl' AND name = 'domains' AND
              parent_id IS NULL;
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl', id, 'mechs', 'PLAIN'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl' AND name = '127.0.0.1' AND
              parent_id IN (
                  SELECT id
                      FROM configuration.properties
                      WHERE pid = 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl' AND name = 'domains' AND
                            parent_id IS NULL
              );

INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl', id, 'jabber.dev.rambler.ru', ''
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl' AND name = 'domains' AND
              parent_id IS NULL;
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl', id, 'mechs', 'PLAIN'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl' AND name = 'jabber.dev.rambler.ru' AND
              parent_id IN (
                  SELECT id
                      FROM configuration.properties
                      WHERE pid = 'ru.rambler.xmpp.server.core.stream.sasl.impl.SaslServiceImpl' AND name = 'domains' AND
                            parent_id IS NULL
              );
              
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.core.net.nio.ConnectionManagerServiceImpl', 'keystore', 
    '/u3+7QAAAAIAAAABAAAAAQAEeG1wcAAAATD5jfw5AAABjzCCAYswDgYKKwYBBAEqAhEBAQUABIIB
dx41aaNOGADCdNVtWrqapu0RQ27DHLtlAC9gpCBvw0pRgD+vd9F1HDPdE43GeIKidy4d18R04S+2
2A15DYz5fNBnPCHSpfXkeiE5EOToBk8366sezgjUhybPPFmbDccMZtQXq9AcN7/fxUMXx/k9oUIz
i8xDtWNgKbszqjTbqsrlO2OAHICjVzrsyu2mVE0pajGhU/7u2r3IPCq6Rz/RZAlN25DpbG9ppbWh
2nIJaZ4Rc3njsz7kSqF7pzF5XFh9vbmWg/EfQjdqGiOcRa7PpNMpo1mdCkpujFn9TB/HEc2sBKGA
aI6SRDqSi3WsA9PtSl6IVb/Ik+NHi1EisRGRLAH/HF1/dBkGVCy0d6g6L/V17VxrNtozi0NorBu8
lT6Tqe0KeGdmyg+lIVAmLDjc9TymtXoobJPnkUwL1f4Tga1pfwpjCXdUKOW8ObDoTm5/BAmzOkze
QFWPJcYJDbR3KKMzlpfDX5qFLPLoVr038e4ImnK8JGvDLAAAAAEABVguNTA5AAADDjCCAwowggLI
oAMCAQICBE4S1HgwCwYHKoZIzjgEAwUAMGgxCzAJBgNVBAYTAlJVMQ8wDQYDVQQIEwZNb3Njb3cx
DzANBgNVBAcTBk1vc2NvdzEQMA4GA1UEChMHUmFtYmxlcjEQMA4GA1UECxMHUmFtYmxlcjETMBEG
A1UEAxMKamFiYmVyVGVzdDAeFw0xMTA3MDUwOTA4MDhaFw0xOTA5MjEwOTA4MDhaMGgxCzAJBgNV
BAYTAlJVMQ8wDQYDVQQIEwZNb3Njb3cxDzANBgNVBAcTBk1vc2NvdzEQMA4GA1UEChMHUmFtYmxl
cjEQMA4GA1UECxMHUmFtYmxlcjETMBEGA1UEAxMKamFiYmVyVGVzdDCCAbgwggEsBgcqhkjOOAQB
MIIBHwKBgQD9f1OBHXUSKVLfSpwu7OTn9hG3UjzvRADDHj+AtlEmaUVdQCJR+1k9jVj6v8X1ujD2
y5tVbNeBO4AdNG/yZmC3a5lQpaSfn+gEexAiwk+7qdf+t8Yb+DtX58aophUPBPuD9tPFHsMCNVQT
WhaRMvZ1864rYdcq7/IiAxmd0UgBxwIVAJdgUI8VIwvMspK5gqLrhAvwWBz1AoGBAPfhoIXWmz3e
y7yrXDa4V7l5lK+7+jrqgvlXTAs9B4JnUVlXjrrUWU/mcQcQgYC0SRZxI+hMKBYTt88JMozIpuE8
FnqLVHyNKOCjrh4rs6Z1kW6jfwv6ITVi8ftiegEkO8yk8b6oUZCJqIPf4VrlnwaSi2ZegHtVJWQB
TDv+z0kqA4GFAAKBgQDZyry7jFdDU9dtF2qJg/97WItt/HFb1z2JM/CB0EVLA0vfvJhjpfgc3cvb
e1SvuthlAURwoRrd99H3DBpRZdse5q34Huu3Am4qYZoo4vyiSkcdwM7PH4UcCs7Hk4KsIhpLRG+u
hGDi9b5XAHTQ7MI311acaU3CaMJC0MNIqdmhhjALBgcqhkjOOAQDBQADLwAwLAIUAZfaU5AWKXk6
Brklc66rzQllrRACFFxj6Nxt+CChMZgchgijIWJ+J3MWbV0R7Yh3SWV6VTxWU4dK0Hq9I2s=');
    
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.core.net.nio.ConnectionManagerServiceImpl', 'keypass', 'changeit'); 
              

CREATE UNIQUE INDEX ndx__properties_tree ON configuration.properties (pid, id);
ALTER TABLE configuration.properties ADD PRIMARY KEY (id);
ALTER TABLE configuration.properties
    ADD CONSTRAINT constraint__properties_parent
        FOREIGN KEY (parent_id)
            REFERENCES configuration.properties (id) ON DELETE CASCADE;
ALTER TABLE configuration.properties
    ADD CONSTRAINT constraint__properties_tree
        FOREIGN KEY (pid, parent_id)
            REFERENCES configuration.properties (pid, id) ON UPDATE CASCADE ON DELETE CASCADE;

INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.janitor.impl.PgJanitor', 'user_timeout', '0');
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.janitor.impl.PgJanitor', 'contact_timeout', '1 month');
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.janitor.impl.PgJanitor', 'message_timeout', '1 month');


-- INSERT INTO configuration.properties (pid, name, value)
--     VALUES ('ru.rambler.xmpp.server.core.cluster.impl.ClusterServiceImpl', 'ru.rambler.xmpp.server.core.routing.impl.RoutingServiceImpl', '1');
-- INSERT INTO configuration.properties (pid, name, value)
--     VALUES ('ru.rambler.xmpp.server.core.cluster.impl.ClusterServiceImpl', 'ru.rambler.xmpp.server.core.handler.presence.impl.PresenceServiceImpl', '2');

INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.core.cluster.impl.ClusterServiceImpl', 'services', '');
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.core.cluster.impl.ClusterServiceImpl', id, 'ru.rambler.xmpp.server.core.routing.impl.RoutingServiceImpl', '1'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.core.cluster.impl.ClusterServiceImpl' AND name = 'services' AND
              parent_id IS NULL;
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.core.cluster.impl.ClusterServiceImpl', id, 'ru.rambler.xmpp.server.core.handler.presence.impl.PresenceServiceImpl', '2'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.core.cluster.impl.ClusterServiceImpl' AND name = 'services' AND
              parent_id IS NULL;
              
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.api.impl.RamblerApiServiceImpl', 'login_stat_url', 'http://www.rambler.ru/r/p?event=usage&rpid=self&appid=contact');

-- Конфигурация очередей
-- Первый блок - соединение по умолчанию, используется, если идентификатор очереди не связан с идентификатором соединения
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.jms.impl.amq.AMQService', 'uri', 'tcp://localhost:61616');
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.jms.impl.amq.AMQService', 'user', 'xmpp');
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.jms.impl.amq.AMQService', 'password', 'xmpp');
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.jms.impl.amq.AMQService', 'pool_size', '64');
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.jms.impl.amq.AMQService', 'queue_prefetch', '4000');
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.jms.impl.amq.AMQService', 'queue_timeout', '100');

-- Конфигурация соединений - список
-- Соединение для истории 1
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.jms.impl.amq.AMQService', 'connection', 'HistoryDatabase.1');
-- Параметры соединения
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.jms.impl.amq.AMQService', id, 'uri', 'tcp://localhost:61616'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.jms.impl.amq.AMQService' AND
              name = 'connection' AND value = 'HistoryDatabase.1';
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.jms.impl.amq.AMQService', id, 'user', 'xmpp'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.jms.impl.amq.AMQService' AND
              name = 'connection' AND value = 'HistoryDatabase.1';
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.jms.impl.amq.AMQService', id, 'password', 'xmpp'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.jms.impl.amq.AMQService' AND
              name = 'connection' AND value = 'HistoryDatabase.1';
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.jms.impl.amq.AMQService', id, 'pool_size', '64'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.jms.impl.amq.AMQService' AND
              name = 'connection' AND value = 'HistoryDatabase.1';
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.jms.impl.amq.AMQService', id, 'queue_prefetch', '4000'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.jms.impl.amq.AMQService' AND
              name = 'connection' AND value = 'HistoryDatabase.1';
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.jms.impl.amq.AMQService', id, 'queue_timeout', '100'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.jms.impl.amq.AMQService' AND
              name = 'connection' AND value = 'HistoryDatabase.1';
-- Очереди, привязанные к соединению
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.jms.impl.amq.AMQService', id, 'queue', 'HistoryDatabase.1'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.jms.impl.amq.AMQService' AND
              name = 'connection' AND value = 'HistoryDatabase.1';


-- Соединение для истории 2
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.jms.impl.amq.AMQService', 'connection', 'HistoryDatabase.2');
-- Параметры соединения
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.jms.impl.amq.AMQService', id, 'uri', 'tcp://localhost:61616'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.jms.impl.amq.AMQService' AND
              name = 'connection' AND value = 'HistoryDatabase.2';
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.jms.impl.amq.AMQService', id, 'user', 'xmpp'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.jms.impl.amq.AMQService' AND
              name = 'connection' AND value = 'HistoryDatabase.2';
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.jms.impl.amq.AMQService', id, 'password', 'xmpp'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.jms.impl.amq.AMQService' AND
              name = 'connection' AND value = 'HistoryDatabase.2';
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.jms.impl.amq.AMQService', id, 'pool_size', '64'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.jms.impl.amq.AMQService' AND
              name = 'connection' AND value = 'HistoryDatabase.2';
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.jms.impl.amq.AMQService', id, 'queue_prefetch', '4000'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.jms.impl.amq.AMQService' AND
              name = 'connection' AND value = 'HistoryDatabase.2';
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.jms.impl.amq.AMQService', id, 'queue_timeout', '100'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.jms.impl.amq.AMQService' AND
              name = 'connection' AND value = 'HistoryDatabase.2';
-- Очереди, привязанные к соединению
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.jms.impl.amq.AMQService', id, 'queue', 'HistoryDatabase.2'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.jms.impl.amq.AMQService' AND
              name = 'connection' AND value = 'HistoryDatabase.2';

-- Соединение для истории 3
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.jms.impl.amq.AMQService', 'connection', 'HistoryDatabase.3');
-- Параметры соединения
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.jms.impl.amq.AMQService', id, 'uri', 'tcp://localhost:61616'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.jms.impl.amq.AMQService' AND
              name = 'connection' AND value = 'HistoryDatabase.3';
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.jms.impl.amq.AMQService', id, 'user', 'xmpp'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.jms.impl.amq.AMQService' AND
              name = 'connection' AND value = 'HistoryDatabase.3';
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.jms.impl.amq.AMQService', id, 'password', 'xmpp'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.jms.impl.amq.AMQService' AND
              name = 'connection' AND value = 'HistoryDatabase.3';
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.jms.impl.amq.AMQService', id, 'pool_size', '64'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.jms.impl.amq.AMQService' AND
              name = 'connection' AND value = 'HistoryDatabase.3';
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.jms.impl.amq.AMQService', id, 'queue_prefetch', '4000'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.jms.impl.amq.AMQService' AND
              name = 'connection' AND value = 'HistoryDatabase.3';
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.jms.impl.amq.AMQService', id, 'queue_timeout', '100'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.jms.impl.amq.AMQService' AND
              name = 'connection' AND value = 'HistoryDatabase.3';
-- Очереди, привязанные к соединению
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.jms.impl.amq.AMQService', id, 'queue', 'HistoryDatabase.3'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.jms.impl.amq.AMQService' AND
              name = 'connection' AND value = 'HistoryDatabase.3';

-- Соединение для истории 4
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.jms.impl.amq.AMQService', 'connection', 'HistoryDatabase.4');
-- Параметры соединения
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.jms.impl.amq.AMQService', id, 'uri', 'tcp://localhost:61616'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.jms.impl.amq.AMQService' AND
              name = 'connection' AND value = 'HistoryDatabase.4';
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.jms.impl.amq.AMQService', id, 'user', 'xmpp'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.jms.impl.amq.AMQService' AND
              name = 'connection' AND value = 'HistoryDatabase.4';
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.jms.impl.amq.AMQService', id, 'password', 'xmpp'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.jms.impl.amq.AMQService' AND
              name = 'connection' AND value = 'HistoryDatabase.4';
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.jms.impl.amq.AMQService', id, 'pool_size', '64'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.jms.impl.amq.AMQService' AND
              name = 'connection' AND value = 'HistoryDatabase.4';
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.jms.impl.amq.AMQService', id, 'queue_prefetch', '4000'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.jms.impl.amq.AMQService' AND
              name = 'connection' AND value = 'HistoryDatabase.4';
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.jms.impl.amq.AMQService', id, 'queue_timeout', '100'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.jms.impl.amq.AMQService' AND
              name = 'connection' AND value = 'HistoryDatabase.4';
-- Очереди, привязанные к соединению
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.jms.impl.amq.AMQService', id, 'queue', 'HistoryDatabase.4'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.jms.impl.amq.AMQService' AND
              name = 'connection' AND value = 'HistoryDatabase.4';

-- Соединение для логирования 1
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.jms.impl.amq.AMQService', 'connection', 'LogMessagesDatabase.1');

-- Параметры соединения
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.jms.impl.amq.AMQService', id, 'uri', 'tcp://localhost:61616'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.jms.impl.amq.AMQService' AND
              name = 'connection' AND value = 'LogMessagesDatabase.1';
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.jms.impl.amq.AMQService', id, 'user', 'xmpp'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.jms.impl.amq.AMQService' AND
              name = 'connection' AND value = 'LogMessagesDatabase.1';
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.jms.impl.amq.AMQService', id, 'password', 'xmpp'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.jms.impl.amq.AMQService' AND
              name = 'connection' AND value = 'LogMessagesDatabase.1';
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.jms.impl.amq.AMQService', id, 'pool_size', '64'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.jms.impl.amq.AMQService' AND
              name = 'connection' AND value = 'LogMessagesDatabase.1';
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.jms.impl.amq.AMQService', id, 'queue_prefetch', '4000'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.jms.impl.amq.AMQService' AND
              name = 'connection' AND value = 'LogMessagesDatabase.1';
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.jms.impl.amq.AMQService', id, 'queue_timeout', '100'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.jms.impl.amq.AMQService' AND
              name = 'connection' AND value = 'LogMessagesDatabase.1';
-- Очереди, привязанные к соединению
INSERT INTO configuration.properties (pid, parent_id, name, value)
    SELECT 'ru.rambler.xmpp.server.jms.impl.amq.AMQService', id, 'queue', 'LogMessagesDatabase.1'
        FROM configuration.properties
        WHERE pid = 'ru.rambler.xmpp.server.jms.impl.amq.AMQService' AND
              name = 'connection' AND value = 'LogMessagesDatabase.1';

COMMIT;
