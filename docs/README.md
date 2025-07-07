# Easy RSVP - Documentation Overview

This directory contains comprehensive documentation for deploying and understanding the Easy RSVP application database structure.

## 📋 Quick Reference

| Document | Purpose | Use Case |
|----------|---------|----------|
| [ERD.md](ERD.md) | Entity Relationship Diagram | Understanding database structure and relationships |
| [database_setup.sql](database_setup.sql) | Complete database creation script | Setting up database on new servers |
| [DEPLOYMENT.md](DEPLOYMENT.md) | Full deployment guide | Complete server setup and migration |

## 🗄️ Database Files

### ERD.md
- **Visual database schema** with ASCII diagrams
- **Relationship explanations** between all tables
- **Key features overview** of the application
- **Database constraints** and validation rules

### database_setup.sql
- **Production-ready SQL script** for PostgreSQL 12+
- **Complete table creation** with proper indexes
- **Foreign key constraints** for data integrity
- **Rails compatibility** with schema_migrations table
- **Performance optimizations** and documentation comments

## 🚀 Deployment Files

### DEPLOYMENT.md
- **Step-by-step server setup** instructions
- **Two deployment options**: SQL script vs Rails migrations
- **Web server configuration** (Nginx example)
- **Security considerations** and best practices
- **Backup and monitoring** strategies
- **Troubleshooting guide** for common issues

## 📊 Database Schema Summary

The Easy RSVP application uses **7 core tables**:

### Primary Tables
1. **events** - Main event information and settings
2. **rsvps** - Guest responses (yes/maybe/no)
3. **custom_fields** - Dynamic form fields for events
4. **custom_field_responses** - Guest responses to custom fields

### Supporting Tables
5. **image_uploads** - Rich text editor file support
6. **active_storage_blobs** - File storage metadata
7. **active_storage_attachments** - File associations

### Key Features
- ✅ **Accountless design** - No user registration required
- ✅ **Session-based tracking** - RSVPs linked to browser sessions
- ✅ **Secure admin access** - UUID-based admin tokens
- ✅ **Custom fields** - Dynamic form builder for additional data
- ✅ **Rich content** - Trix editor with file upload support
- ✅ **Privacy controls** - Hide guest names option

## 🔧 Usage Instructions

### For New Server Deployment

1. **Review the ERD** to understand the database structure
2. **Use database_setup.sql** to create the database schema
3. **Follow DEPLOYMENT.md** for complete server setup

### For Development Understanding

1. **Start with ERD.md** to understand relationships
2. **Reference database_setup.sql** for exact table structures
3. **Check DEPLOYMENT.md** for environment configuration

### For Database Migration

1. **Backup existing data** using pg_dump
2. **Run database_setup.sql** on new server
3. **Import data** using pg_restore (data-only)
4. **Follow DEPLOYMENT.md** security guidelines

## 🔍 Schema Version

- **Current Version**: 20250707055835
- **Rails Version**: 7.2.2.1
- **PostgreSQL**: 12+ required
- **Extensions**: pgcrypto, plpgsql, uuid-ossp

## 📝 Related Documentation

In the main project directory:
- `CHANGELOG.md` - Application change history
- `CUSTOM_FIELDS.md` - Custom fields feature documentation
- `README.md` - Main project documentation

## 🆘 Support

For deployment issues:
1. Check **DEPLOYMENT.md** troubleshooting section
2. Verify database schema with ERD.md
3. Ensure all foreign key constraints are properly created
4. Review Rails logs for specific error messages

## 🔐 Security Notes

- Always use **strong passwords** for database users
- Keep **SECRET_KEY_BASE** secure and unique per environment
- Use **HTTPS only** in production
- Regularly **backup your database**
- Monitor **application logs** for security issues

---

*Generated for Easy RSVP application - A simple, accountless event management and RSVP system*
