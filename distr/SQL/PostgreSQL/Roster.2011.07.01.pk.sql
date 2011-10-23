BEGIN;

ALTER TABLE roster.contacts DROP CONSTRAINT contacts_user_id_fkey;
ALTER TABLE roster.transports DROP CONSTRAINT transports_pkey;
ALTER TABLE roster.transports ADD CONSTRAINT transports_surrogate_key UNIQUE (user_id, id);
ALTER TABLE roster.contacts ADD CONSTRAINT contacts_transport_foreign_key FOREIGN KEY (user_id, transport_id) REFERENCES roster.transports (user_id, id) ON DELETE CASCADE;
ALTER TABLE roster.transports DROP CONSTRAINT transports_user_id_gateway_id_name_key;
ALTER TABLE roster.transports ADD CONSTRAINT transports_primary_key PRIMARY KEY (user_id, name);
UPDATE roster.transports SET name = '' WHERE gateway_id = 0;
ALTER TABLE roster.transports ADD CONSTRAINT transports_native_check CHECK ((gateway_id = 0) = (name = ''));

ALTER TABLE roster.contacts DROP CONSTRAINT contacts_pkey;
ALTER TABLE roster.contacts ADD CONSTRAINT contacts_surrogate_key UNIQUE (user_id, id);
ALTER TABLE roster.contacts DROP CONSTRAINT contacts_user_id_transport_id_jid_name_jid_domain_key;
ALTER TABLE roster.contacts ADD CONSTRAINT contacts_primary_key PRIMARY KEY (user_id, jid_name, jid_domain);

COMMIT;