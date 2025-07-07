-- Easy RSVP Database Setup Script
-- This script creates the complete database structure for Easy RSVP application
-- Compatible with PostgreSQL 12+

-- Enable required PostgreSQL extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "plpgsql";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create the main events table
CREATE TABLE events (
    id bigserial PRIMARY KEY,
    title character varying NOT NULL,
    date date NOT NULL,
    body text,
    admin_token character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    show_rsvp_names boolean DEFAULT true NOT NULL,
    published boolean DEFAULT true
);

-- Create the rsvps table
CREATE TABLE rsvps (
    id bigserial PRIMARY KEY,
    event_id bigint,
    name character varying,
    response character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

-- Create index on rsvps.event_id for performance
CREATE INDEX index_rsvps_on_event_id ON rsvps USING btree (event_id);

-- Create the custom_fields table
CREATE TABLE custom_fields (
    id bigserial PRIMARY KEY,
    event_id bigint NOT NULL,
    field_name character varying(255) NOT NULL,
    field_type character varying NOT NULL,
    required boolean DEFAULT false NOT NULL,
    options text,
    position integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

-- Create indexes on custom_fields
CREATE INDEX index_custom_fields_on_event_id ON custom_fields USING btree (event_id);
CREATE INDEX index_custom_fields_on_event_id_and_position ON custom_fields USING btree (event_id, position);

-- Create the custom_field_responses table
CREATE TABLE custom_field_responses (
    id bigserial PRIMARY KEY,
    rsvp_id bigint NOT NULL,
    custom_field_id bigint NOT NULL,
    response_value character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

-- Create indexes on custom_field_responses
CREATE INDEX index_custom_field_responses_on_rsvp_id ON custom_field_responses USING btree (rsvp_id);
CREATE INDEX index_custom_field_responses_on_custom_field_id ON custom_field_responses USING btree (custom_field_id);
CREATE UNIQUE INDEX index_custom_field_responses_on_rsvp_id_and_custom_field_id ON custom_field_responses USING btree (rsvp_id, custom_field_id);

-- Create the image_uploads table (for Trix editor support)
CREATE TABLE image_uploads (
    id bigserial PRIMARY KEY,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

-- Create Active Storage tables (for file uploads)
CREATE TABLE active_storage_blobs (
    id bigserial PRIMARY KEY,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    byte_size bigint NOT NULL,
    checksum character varying,
    created_at timestamp without time zone NOT NULL,
    service_name character varying NOT NULL
);

-- Create unique index on active_storage_blobs.key
CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON active_storage_blobs USING btree (key);

CREATE TABLE active_storage_attachments (
    id bigserial PRIMARY KEY,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL
);

-- Create indexes on active_storage_attachments
CREATE INDEX index_active_storage_attachments_on_blob_id ON active_storage_attachments USING btree (blob_id);
CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON active_storage_attachments USING btree (record_type, record_id, name, blob_id);

CREATE TABLE active_storage_variant_records (
    id bigserial PRIMARY KEY,
    blob_id integer NOT NULL,
    variation_digest character varying NOT NULL
);

-- Create unique index on active_storage_variant_records
CREATE UNIQUE INDEX index_active_storage_variant_records_uniqueness ON active_storage_variant_records USING btree (blob_id, variation_digest);

-- Add foreign key constraints
ALTER TABLE ONLY rsvps
    ADD CONSTRAINT fk_rails_rsvps_events FOREIGN KEY (event_id) REFERENCES events(id);

ALTER TABLE ONLY custom_fields
    ADD CONSTRAINT fk_rails_custom_fields_events FOREIGN KEY (event_id) REFERENCES events(id);

ALTER TABLE ONLY custom_field_responses
    ADD CONSTRAINT fk_rails_custom_field_responses_rsvps FOREIGN KEY (rsvp_id) REFERENCES rsvps(id);

ALTER TABLE ONLY custom_field_responses
    ADD CONSTRAINT fk_rails_custom_field_responses_custom_fields FOREIGN KEY (custom_field_id) REFERENCES custom_fields(id);

ALTER TABLE ONLY active_storage_variant_records
    ADD CONSTRAINT fk_rails_active_storage_variant_records_blobs FOREIGN KEY (blob_id) REFERENCES active_storage_blobs(id);

-- Create schema_migrations table (Rails requirement)
CREATE TABLE schema_migrations (
    version character varying NOT NULL
);

-- Create unique index on schema_migrations.version
CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);

-- Insert current schema version
INSERT INTO schema_migrations (version) VALUES ('20250707055835');

-- Create ar_internal_metadata table (Rails requirement)
CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

-- Create primary key on ar_internal_metadata
ALTER TABLE ONLY ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);

-- Insert Rails environment metadata
INSERT INTO ar_internal_metadata (key, value, created_at, updated_at) 
VALUES ('environment', 'production', NOW(), NOW());

-- Grant permissions (adjust username as needed)
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO your_app_user;
-- GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO your_app_user;

-- Performance optimizations
ANALYZE;

-- Comments for documentation
COMMENT ON TABLE events IS 'Main events table storing event information and settings';
COMMENT ON TABLE rsvps IS 'Guest responses to events with yes/maybe/no options';
COMMENT ON TABLE custom_fields IS 'Dynamic form fields for collecting additional RSVP information';
COMMENT ON TABLE custom_field_responses IS 'Guest responses to custom fields';
COMMENT ON TABLE image_uploads IS 'Support table for Trix rich text editor file uploads';

COMMENT ON COLUMN events.admin_token IS 'UUID token for secure admin access to event management';
COMMENT ON COLUMN events.show_rsvp_names IS 'Controls whether guest names are visible to other guests';
COMMENT ON COLUMN events.published IS 'Controls whether event is publicly accessible';
COMMENT ON COLUMN custom_fields.field_type IS 'Type of field: text or dropdown';
COMMENT ON COLUMN custom_fields.options IS 'JSON array of options for dropdown fields';
COMMENT ON COLUMN custom_fields.position IS 'Display order of custom fields';
COMMENT ON COLUMN custom_field_responses.response_value IS 'Guest response to custom field (max 255 chars)';
