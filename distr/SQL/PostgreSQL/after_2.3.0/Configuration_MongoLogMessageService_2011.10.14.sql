-- Сервис персонального логирования --
INSERT INTO configuration.pids (pid) VALUES ('ru.rambler.xmpp.server.core.log.impl.MongoLogMessageServiceImpl');
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.core.log.impl.MongoLogMessageServiceImpl', 'host', 'localhost');
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.core.log.impl.MongoLogMessageServiceImpl', 'port', '27017');
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.core.log.impl.MongoLogMessageServiceImpl', 'dbName', 'logging');
INSERT INTO configuration.properties (pid, name, value)
    VALUES ('ru.rambler.xmpp.server.core.log.impl.MongoLogMessageServiceImpl', 'collectioName', 'osgiTestCollection');

