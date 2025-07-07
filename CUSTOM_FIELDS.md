# Custom Fields Feature Documentation

This document provides technical details about the Custom Fields feature implementation in Easy RSVP.

## Overview

The Custom Fields feature allows event organizers to add custom questions when creating events. Guests must answer these questions when RSVPing, and organizers can view all responses in the admin panel.

## Database Schema

### custom_fields Table
```sql
CREATE TABLE custom_fields (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  field_name VARCHAR(255) NOT NULL,
  field_type VARCHAR(50) NOT NULL DEFAULT 'text',
  required BOOLEAN NOT NULL DEFAULT false,
  options TEXT, -- JSON array for dropdown options
  position INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

CREATE INDEX index_custom_fields_on_event_id ON custom_fields(event_id);
CREATE INDEX index_custom_fields_on_position ON custom_fields(position);
```

### custom_field_responses Table
```sql
CREATE TABLE custom_field_responses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  rsvp_id UUID NOT NULL REFERENCES rsvps(id) ON DELETE CASCADE,
  custom_field_id UUID NOT NULL REFERENCES custom_fields(id) ON DELETE CASCADE,
  response_value TEXT,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

CREATE INDEX index_custom_field_responses_on_rsvp_id ON custom_field_responses(rsvp_id);
CREATE INDEX index_custom_field_responses_on_custom_field_id ON custom_field_responses(custom_field_id);
```

## Models

### CustomField Model
```ruby
class CustomField < ApplicationRecord
  FIELD_TYPES = %w[text dropdown].freeze
  
  belongs_to :event
  has_many :custom_field_responses, dependent: :destroy
  
  validates :field_name, presence: true, length: { maximum: 255 }
  validates :field_type, presence: true, inclusion: { in: FIELD_TYPES }
  validates :position, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  scope :ordered, -> { order(:position) }
  
  # JSON serialization for dropdown options
  def options_array
    return [] if options.blank?
    JSON.parse(options)
  rescue JSON::ParserError
    []
  end
  
  def options_array=(array)
    self.options = array.present? ? array.to_json : nil
  end
end
```

### CustomFieldResponse Model
```ruby
class CustomFieldResponse < ApplicationRecord
  belongs_to :rsvp
  belongs_to :custom_field
  
  validates :response_value, presence: true, if: -> { custom_field&.required? }
  validates :response_value, length: { maximum: 255 }
end
```

## Controllers

### EventsController Changes
```ruby
# Added to private methods
def custom_fields_params
  params[:custom_fields] || {}
end

def create_custom_fields
  return if custom_fields_params.blank?
  
  custom_fields_params.each.with_index do |(key, field_data), index|
    next if field_data[:field_name].blank? || field_data[:field_type].blank?
    
    custom_field = @event.custom_fields.build(
      field_name: field_data[:field_name],
      field_type: field_data[:field_type],
      required: field_data[:required] == '1',
      position: index
    )
    
    if field_data[:field_type] == 'dropdown' && field_data[:options].present?
      options_array = field_data[:options].split("\n").map(&:strip).reject(&:blank?)
      custom_field.options_array = options_array
    end
    
    custom_field.save!
  end
end
```

### RsvpsController Changes
```ruby
# Added to private methods
def custom_field_responses_params
  params[:custom_field_responses] || {}
end

def create_custom_field_responses
  return if custom_field_responses_params.blank?
  
  custom_field_responses_params.each do |custom_field_id, response_value|
    next if response_value.blank?
    
    @rsvp.custom_field_responses.create!(
      custom_field_id: custom_field_id,
      response_value: response_value
    )
  end
end
```

## Frontend Implementation

### Dynamic Form Builder (JavaScript)
The event creation form includes JavaScript to dynamically add/remove custom fields:

```javascript
// Add custom field functionality
document.addEventListener('DOMContentLoaded', function() {
  let fieldIndex = 0;
  
  document.getElementById('add-custom-field').addEventListener('click', function(e) {
    e.preventDefault();
    
    const fieldHtml = `
      <div class="custom-field-row" data-index="${fieldIndex}">
        <div class="row">
          <div class="col-md-4">
            <label>Field Name:</label>
            <input type="text" name="custom_fields[${fieldIndex}][field_name]" 
                   class="form-control" placeholder="e.g., Dietary restrictions">
          </div>
          <div class="col-md-3">
            <label>Field Type:</label>
            <select name="custom_fields[${fieldIndex}][field_type]" class="form-control">
              <option value="text">Text</option>
              <option value="dropdown">Dropdown</option>
            </select>
          </div>
          <div class="col-md-2">
            <label>&nbsp;</label>
            <div class="form-check">
              <input type="checkbox" name="custom_fields[${fieldIndex}][required]" 
                     value="1" class="form-check-input">
              <label class="form-check-label">Required</label>
            </div>
          </div>
          <div class="col-md-3">
            <label>&nbsp;</label>
            <button type="button" class="btn btn-danger remove-field">Remove</button>
          </div>
        </div>
      </div>
    `;
    
    document.getElementById('custom-fields-container').insertAdjacentHTML('beforeend', fieldHtml);
    fieldIndex++;
  });
  
  // Remove field functionality
  document.addEventListener('click', function(e) {
    if (e.target.classList.contains('remove-field')) {
      e.target.closest('.custom-field-row').remove();
    }
  });
});
```

### RSVP Form Integration
Custom fields are automatically rendered in the RSVP form:

```erb
<% @event.custom_fields.ordered.each do |custom_field| %>
  <div class="form-group">
    <%= label_tag "custom_field_responses[#{custom_field.id}]", custom_field.field_name %>
    <% if custom_field.required? %>
      <span class="text-danger">*</span>
    <% end %>
    
    <% if custom_field.field_type == 'text' %>
      <%= text_field_tag "custom_field_responses[#{custom_field.id}]", '', 
                         class: 'form-control', 
                         required: custom_field.required? %>
    <% elsif custom_field.field_type == 'dropdown' %>
      <%= select_tag "custom_field_responses[#{custom_field.id}]", 
                     options_for_select([['Select...', '']] + custom_field.options_array.map { |opt| [opt, opt] }), 
                     class: 'form-control', 
                     required: custom_field.required? %>
    <% end %>
  </div>
<% end %>
```

## Admin Panel Integration

The admin panel displays custom field responses alongside RSVP data:

```erb
<h3>Custom Fields</h3>
<% @event.custom_fields.ordered.each do |custom_field| %>
  <h4><%= custom_field.field_name %> (<%= custom_field.field_type.humanize %>)</h4>
  
  <% %w[yes maybe no].each do |response_type| %>
    <h5><%= response_type.humanize %> (<%= @rsvps.select { |r| r.response == response_type }.count %>)</h5>
    <ul>
      <% @rsvps.select { |r| r.response == response_type }.each do |rsvp| %>
        <li>
          <%= rsvp.name %>
          <% response = rsvp.custom_field_responses.find { |cfr| cfr.custom_field_id == custom_field.id } %>
          <% if response %>
            - <%= custom_field.field_name %>: <%= response.response_value %>
          <% end %>
        </li>
      <% end %>
    </ul>
  <% end %>
<% end %>
```

## Future Enhancements

### Planned Field Types
- **Email**: Email validation
- **Phone**: Phone number formatting
- **Number**: Numeric input with min/max validation
- **Date**: Date picker integration
- **Checkbox**: Multiple selection options
- **Radio**: Single selection from multiple options

### Additional Features
- **Field Validation**: Custom validation rules per field type
- **Conditional Fields**: Show/hide fields based on other responses
- **Field Ordering**: Drag-and-drop reordering in admin interface
- **Export Functionality**: CSV export of all responses including custom fields
- **Field Templates**: Pre-defined field sets for common event types

## Testing

### Model Tests
```ruby
RSpec.describe CustomField, type: :model do
  it { should belong_to(:event) }
  it { should have_many(:custom_field_responses).dependent(:destroy) }
  it { should validate_presence_of(:field_name) }
  it { should validate_inclusion_of(:field_type).in_array(%w[text dropdown]) }
end

RSpec.describe CustomFieldResponse, type: :model do
  it { should belong_to(:rsvp) }
  it { should belong_to(:custom_field) }
end
```

### Integration Tests
```ruby
RSpec.describe "Custom Fields", type: :feature do
  scenario "Event organizer adds custom fields" do
    visit root_path
    fill_in "Event Title", with: "Test Event"
    click_button "Add Custom Field"
    fill_in "Field Name", with: "Dietary Restrictions"
    click_button "Create Event"
    
    expect(page).to have_content("Dietary Restrictions")
  end
  
  scenario "Guest fills out custom fields during RSVP" do
    event = create(:event_with_custom_fields)
    visit event_path(event)
    
    fill_in "Your name", with: "John Doe"
    fill_in "Dietary Restrictions", with: "Vegetarian"
    click_button "Yes"
    
    expect(page).to have_content("Thank you for responding!")
  end
end
```

## Performance Considerations

- **Database Indexes**: Proper indexing on foreign keys and frequently queried columns
- **N+1 Queries**: Use `includes(:custom_fields, :custom_field_responses)` when loading events with responses
- **Caching**: Consider caching custom field definitions for high-traffic events
- **Validation**: Client-side validation to reduce server requests

## Security Considerations

- **Input Sanitization**: All custom field responses are sanitized before storage
- **Length Limits**: Maximum 255 characters for text responses
- **XSS Prevention**: Proper escaping when displaying user-generated content
- **CSRF Protection**: All forms include CSRF tokens
