BEGIN;

INSERT INTO configuration.pids (pid) VALUES ('ru.rambler.xmpp.server.core.log.impl.PgLogMessageService');

INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.core.log.impl.PgLogMessageService', 'queue_timeout', '10');
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.core.log.impl.PgLogMessageService', 'messages_bulk_size', '4000');

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