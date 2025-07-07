# Easy RSVP

An accountless app to organize events and invite people.
This is a port from the original project: https://github.com/KevinBongart/easy-rsvp

## Features

### Core Features
- **Accountless Design**: No user registration required - manage events with secure admin tokens
- **Simple Event Creation**: Create events with title, date, and description
- **Easy RSVP Process**: Guests can RSVP with just their name - no account needed
- **Real-time Updates**: See RSVP responses immediately
- **Admin Panel**: Secure event management with unique admin URLs

### Custom Fields (New!)
- **Dynamic Custom Questions**: Add custom fields when creating events
- **Flexible Field Types**: Support for text input fields
- **Required Fields**: Mark custom fields as required or optional with validation
- **Guest Responses**: Custom field responses are collected during RSVP
- **Admin Visibility**: View all custom field responses in the admin panel
- **Form Validation**: Required fields are validated both client-side and server-side

## How It Works

### For Event Organizers
1. **Create an Event**: Visit the homepage and fill out event details
2. **Add Custom Fields** (Optional): Click "Add Custom Field" to add questions like:
   - Dietary restrictions
   - Plus-one information
   - Special requests
   - Contact information
3. **Share the Link**: Get a public RSVP link to share with guests
4. **Manage Responses**: Use the admin link to view all RSVPs and custom field responses

### For Guests
1. **Visit RSVP Link**: Click the link shared by the event organizer
2. **Fill Out Form**: Enter your name and any custom field responses
3. **Choose Response**: Click Yes, Maybe, or No
4. **Done**: Your RSVP is recorded instantly

## Technical Details

### Built With
- **Ruby on Rails 7.2.2.1**
- **PostgreSQL** with UUID support
- **Bootstrap 4** for responsive design
- **Trix Editor** for rich text descriptions
- **Hashid-rails** for secure URL obfuscation

### Database Schema
- **Events**: Core event information
- **RSVPs**: Guest responses
- **Custom Fields**: Event-specific custom questions
- **Custom Field Responses**: Guest answers to custom questions

### Key Features
- **Session-based Tracking**: No accounts needed, uses browser sessions
- **UUID Primary Keys**: Enhanced security and privacy
- **Responsive Design**: Works on desktop and mobile devices
- **Rich Text Support**: Event descriptions support formatting

## Development

### Setup
1. Clone the repository
2. Install dependencies: `bundle install`
3. Setup database: `rails db:setup`
4. Run migrations: `rails db:migrate`
5. Start server: `rails server`

### Database Migrations
The custom fields feature includes two new migrations:
- `create_custom_fields`: Stores custom field definitions
- `create_custom_field_responses`: Stores guest responses to custom fields

### Testing
Run the test suite with: `rspec`

## Deployment

This application is designed to be deployed on platforms like Heroku, with PostgreSQL as the database.

## Privacy & Security

- **No Personal Data Storage**: Only stores what guests voluntarily provide
- **Secure Admin Access**: Admin URLs use cryptographically secure tokens
- **Session-based**: No permanent user accounts or tracking
- **URL Obfuscation**: Event URLs use hashids for privacy

## Contributing

This is an open-source project. Contributions are welcome!

## More Information

Read more about the project: https://www.kevinbongart.net/projects/easy-rsvp.html

## License

See LICENSE file for details.
