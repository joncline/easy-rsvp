# Easy RSVP - Entity Relationship Diagram

## Database Schema Overview

The Easy RSVP application uses PostgreSQL with the following core entities and relationships:

```
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│     EVENTS      │       │     RSVPS       │       │ CUSTOM_FIELDS   │
├─────────────────┤       ├─────────────────┤       ├─────────────────┤
│ id (PK)         │◄─────┐│ id (PK)         │       │ id (PK)         │
│ title           │      ││ event_id (FK)   │       │ event_id (FK)   │◄─┐
│ date            │      ││ name            │       │ field_name      │  │
│ body            │      ││ response        │       │ field_type      │  │
│ admin_token     │      ││ created_at      │       │ required        │  │
│ show_rsvp_names │      ││ updated_at      │       │ options         │  │
│ published       │      │└─────────────────┘       │ position        │  │
│ created_at      │      │         │                │ created_at      │  │
│ updated_at      │      │         │                │ updated_at      │  │
└─────────────────┘      │         │                └─────────────────┘  │
                         │         │                                     │
                         │         │                ┌─────────────────┐  │
                         │         │                │CUSTOM_FIELD_    │  │
                         │         │                │   RESPONSES     │  │
                         │         │                ├─────────────────┤  │
                         │         └───────────────►│ id (PK)         │  │
                         │                          │ rsvp_id (FK)    │  │
                         │                          │ custom_field_id │──┘
                         │                          │   (FK)          │
                         │                          │ response_value  │
                         │                          │ created_at      │
                         │                          │ updated_at      │
                         │                          └─────────────────┘
                         │
                         │         ┌─────────────────┐
                         │         │ IMAGE_UPLOADS   │
                         │         ├─────────────────┤
                         │         │ id (PK)         │
                         │         │ created_at      │
                         │         │ updated_at      │
                         │         └─────────────────┘
                         │
                         │         ┌─────────────────┐
                         │         │ACTIVE_STORAGE_  │
                         │         │   ATTACHMENTS   │
                         │         ├─────────────────┤
                         │         │ id (PK)         │
                         │         │ name            │
                         │         │ record_type     │
                         │         │ record_id       │
                         │         │ blob_id (FK)    │──┐
                         │         │ created_at      │  │
                         │         └─────────────────┘  │
                         │                              │
                         │         ┌─────────────────┐  │
                         │         │ACTIVE_STORAGE_  │  │
                         │         │     BLOBS       │  │
                         │         ├─────────────────┤  │
                         │         │ id (PK)         │◄─┘
                         │         │ key             │
                         │         │ filename        │
                         │         │ content_type    │
                         │         │ metadata        │
                         │         │ byte_size       │
                         │         │ checksum        │
                         │         │ service_name    │
                         │         │ created_at      │
                         │         └─────────────────┘
                         │                    │
                         │         ┌─────────────────┐
                         │         │ACTIVE_STORAGE_  │
                         │         │VARIANT_RECORDS  │
                         │         ├─────────────────┤
                         │         │ id (PK)         │
                         │         │ blob_id (FK)    │──┘
                         │         │ variation_digest│
                         │         └─────────────────┘
```

## Core Relationships

### Primary Application Tables

1. **EVENTS** (Main entity)
   - Contains event information (title, date, description)
   - Has secure admin_token for management
   - Controls visibility settings (show_rsvp_names, published)

2. **RSVPS** (Guest responses)
   - Belongs to an EVENT
   - Contains guest name and response (yes/maybe/no)
   - Links to custom field responses

3. **CUSTOM_FIELDS** (Dynamic form fields)
   - Belongs to an EVENT
   - Defines additional questions for RSVPs
   - Supports text and dropdown field types
   - Has position ordering and required validation

4. **CUSTOM_FIELD_RESPONSES** (Guest answers)
   - Links RSVP to CUSTOM_FIELD
   - Stores the actual response values
   - Validates against field requirements

### Supporting Tables

5. **IMAGE_UPLOADS** (File management)
   - Supports rich text editor attachments

6. **ACTIVE_STORAGE_*** (Rails file storage)
   - Handles file uploads and attachments
   - Supports multiple storage backends (local, S3, etc.)

## Key Features

- **Accountless Design**: No user registration required
- **Session-based Tracking**: RSVPs tracked via browser sessions
- **Secure Admin Access**: UUID-based admin tokens
- **URL Obfuscation**: Hashid-based public URLs
- **Rich Content**: Trix editor with file upload support
- **Custom Fields**: Dynamic form builder for additional RSVP data
- **Privacy Controls**: Option to hide guest names from other attendees

## Database Constraints

- Foreign key relationships ensure data integrity
- Unique constraints prevent duplicate responses
- Position ordering for custom fields
- Field type validation (text/dropdown)
- Response validation against dropdown options
