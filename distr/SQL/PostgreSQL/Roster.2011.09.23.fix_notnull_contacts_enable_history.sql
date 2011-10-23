BEGIN;

ALTER TABLE roster.contacts ALTER COLUMN enable_history DROP NOT NULL;

COMMIT;