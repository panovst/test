
-- serialVersionUID = 10

BEGIN;

ALTER TABLE xmpp.users ADD COLUMN history_save_default BOOLEAN NOT NULL DEFAULT true;

COMMIT;
