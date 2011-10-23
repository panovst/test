BEGIN;

SELECT set_config('xmpp.roster_patch', 'false', false);

CREATE OR REPLACE FUNCTION roster._trg__metacontacts__before_update() RETURNS TRIGGER AS $_$
BEGIN
    IF (NOT(current_setting('xmpp.roster_patch')::BOOLEAN) AND NEW.contacts_amount = 0) THEN
        DELETE FROM roster.metacontacts WHERE user_id = NEW.user_id AND metacontact = NEW.metacontact;
        RETURN NULL;
    END IF;
    RETURN NEW;
END;
$_$ LANGUAGE plpgsql;

ALTER TABLE roster.metacontacts DROP CONSTRAINT metacontacts_contacts_amount_check;
ALTER TABLE roster.metacontacts
    ADD CONSTRAINT metacontacts_contacts_amount_check
    CHECK (current_setting('xmpp.roster_patch')::BOOLEAN AND contacts_amount >= 0 OR contacts_amount > 0);

COMMIT;