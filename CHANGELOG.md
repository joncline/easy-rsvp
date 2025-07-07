# Changelog

All notable changes to Easy RSVP will be documented in this file.

## [Unreleased]

### Added
- **Custom Fields Feature**: Event organizers can now add custom questions when creating events
  - Dynamic form builder with "Add Custom Field" button
  - Support for text input fields with optional/required settings
  - Custom field responses are collected during RSVP process
  - Admin panel displays all custom field responses alongside RSVP data
  - Database schema includes `custom_fields` and `custom_field_responses` tables
  - JavaScript-powered dynamic field management in event creation form

### Technical Changes
- Added `CustomField` model with validations and field type constants
- Added `CustomFieldResponse` model for storing guest responses
- Enhanced `Event` model with `has_many :custom_fields` association
- Enhanced `Rsvp` model with `has_many :custom_field_responses` association
- Updated `EventsController` to handle custom fields creation
- Updated `RsvpsController` to handle custom field responses
- Modified event creation form (`events/new.html.erb`) with dynamic custom fields builder
- Modified RSVP form (`events/show.html.erb`) to display custom fields
- Updated admin panel (`events_admin/show.html.erb`) to show custom field responses
- Added database migrations for custom fields functionality

### Bug Fixes
- Fixed ActionController::Parameters iteration issue in custom fields processing
- Improved parameter handling for nested custom fields data

## Previous Versions

For changes prior to the custom fields feature, see the git commit history.
