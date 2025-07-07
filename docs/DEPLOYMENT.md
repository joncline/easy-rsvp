# Easy RSVP - Server Deployment Guide

This guide explains how to deploy the Easy RSVP application to a new server using the provided database setup files.

## Prerequisites

- PostgreSQL 12+ server
- Ruby 3.3.4
- Node.js 14.15.4
- Web server (Nginx/Apache) with SSL certificate
- Domain name configured

## Database Setup

### Option 1: Using the SQL Script (Recommended for new deployments)

1. **Create Database and User**
   ```bash
   sudo -u postgres psql
   ```
   ```sql
   CREATE DATABASE easy_rsvp_production;
   CREATE USER easy_rsvp_user WITH PASSWORD 'your_secure_password';
   GRANT ALL PRIVILEGES ON DATABASE easy_rsvp_production TO easy_rsvp_user;
   \q
   ```

2. **Run the Database Setup Script**
   ```bash
   psql -U easy_rsvp_user -d easy_rsvp_production -f docs/database_setup.sql
   ```

### Option 2: Using Rails Migrations (For existing Rails environments)

1. **Set up environment variables**
   ```bash
   export DATABASE_URL="postgresql://easy_rsvp_user:your_secure_password@localhost/easy_rsvp_production"
   export RAILS_ENV=production
   ```

2. **Run Rails database setup**
   ```bash
   bundle exec rails db:create
   bundle exec rails db:migrate
   ```

## Application Deployment

### 1. Environment Configuration

Create `.env` file with production settings:
```bash
# Database
DATABASE_URL=postgresql://easy_rsvp_user:your_secure_password@localhost/easy_rsvp_production

# Domain
DOMAIN=your-domain.com

# File Storage (Optional - for S3)
S3_ACCESS_KEY_ID=your_s3_key
S3_SECRET_ACCESS_KEY=your_s3_secret

# Email (Optional - for admin notifications)
SMTP_SERVER=smtp.your-provider.com
SMTP_USERNAME=your_smtp_user
SMTP_PASSWORD=your_smtp_password

# Rails
RAILS_ENV=production
SECRET_KEY_BASE=your_secret_key_base
```

### 2. Generate Secret Key Base
```bash
bundle exec rails secret
```

### 3. Precompile Assets
```bash
RAILS_ENV=production bundle exec rails assets:precompile
```

### 4. Web Server Configuration

#### Nginx Configuration Example
```nginx
server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com;
    
    ssl_certificate /path/to/your/certificate.crt;
    ssl_certificate_key /path/to/your/private.key;
    
    root /path/to/easy-rsvp/public;
    
    location / {
        try_files $uri @app;
    }
    
    location @app {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location ~ ^/(assets|packs)/ {
        expires 1y;
        add_header Cache-Control public;
        add_header ETag "";
        break;
    }
}
```

### 5. Process Management

#### Using Systemd (Recommended)

Create `/etc/systemd/system/easy-rsvp.service`:
```ini
[Unit]
Description=Easy RSVP Rails Application
After=network.target

[Service]
Type=simple
User=deploy
WorkingDirectory=/path/to/easy-rsvp
Environment=RAILS_ENV=production
Environment=DATABASE_URL=postgresql://easy_rsvp_user:password@localhost/easy_rsvp_production
ExecStart=/home/deploy/.rbenv/shims/bundle exec puma -C config/puma.rb
Restart=always

[Install]
WantedBy=multi-user.target
```

Enable and start the service:
```bash
sudo systemctl enable easy-rsvp
sudo systemctl start easy-rsvp
```

## Database Schema Verification

After deployment, verify the database structure matches the ERD:

```sql
-- Check table existence
\dt

-- Verify relationships
SELECT 
    tc.table_name, 
    kcu.column_name, 
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM 
    information_schema.table_constraints AS tc 
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
WHERE constraint_type = 'FOREIGN KEY';
```

## Security Considerations

1. **Database Security**
   - Use strong passwords
   - Limit database user permissions
   - Enable SSL for database connections in production

2. **Application Security**
   - Keep SECRET_KEY_BASE secure and unique
   - Use HTTPS only
   - Regular security updates

3. **File Permissions**
   ```bash
   chmod 600 .env
   chown deploy:deploy /path/to/easy-rsvp
   ```

## Backup Strategy

### Database Backups
```bash
# Daily backup script
pg_dump -U easy_rsvp_user easy_rsvp_production > backup_$(date +%Y%m%d).sql

# Restore from backup
psql -U easy_rsvp_user -d easy_rsvp_production < backup_20250707.sql
```

### File Storage Backups
- If using local storage: backup `storage/` directory
- If using S3: backups handled by AWS

## Monitoring

### Health Check Endpoint
The application provides a health check at `/up` (Rails 7.2+ feature)

### Log Monitoring
```bash
# Application logs
tail -f log/production.log

# System service logs
journalctl -u easy-rsvp -f
```

## Troubleshooting

### Common Issues

1. **Database Connection Errors**
   - Verify DATABASE_URL format
   - Check PostgreSQL service status
   - Confirm user permissions

2. **Asset Loading Issues**
   - Ensure assets are precompiled
   - Check file permissions
   - Verify web server configuration

3. **Custom Fields Not Working**
   - Verify custom_fields and custom_field_responses tables exist
   - Check foreign key constraints
   - Review migration status

### Migration from Development

If migrating from a development environment:

1. **Export Development Data**
   ```bash
   pg_dump -U postgres events_development > development_data.sql
   ```

2. **Import to Production** (after running setup script)
   ```bash
   # Import only data, not schema
   pg_restore --data-only -U easy_rsvp_user -d easy_rsvp_production development_data.sql
   ```

## Performance Optimization

1. **Database Indexes**
   - All necessary indexes are included in the setup script
   - Monitor query performance with `EXPLAIN ANALYZE`

2. **Caching**
   - Enable Rails caching in production
   - Consider Redis for session storage

3. **CDN**
   - Use CDN for static assets
   - Configure S3 + CloudFront for file uploads

## Support

For issues related to:
- **Database Schema**: Reference `docs/ERD.md`
- **Custom Fields**: Reference `CUSTOM_FIELDS.md`
- **Application Changes**: Reference `CHANGELOG.md`

## Version Information

- Database Schema Version: 20250707055835
- Rails Version: 7.2.2.1
- Ruby Version: 3.3.4
- Node.js Version: 14.15.4
