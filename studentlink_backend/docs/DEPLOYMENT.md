# StudentLink Backend Deployment Guide

## Overview

This guide covers deploying the StudentLink Backend API to a Hostinger VPS with KVM 1 configuration using Docker.

## Prerequisites

### Server Requirements
- VPS with KVM 1 (2 CPU cores, 4GB RAM, 50GB SSD)
- Ubuntu 20.04 LTS or higher
- Docker and Docker Compose installed
- Domain name configured (optional but recommended)

### Required Services
- MySQL 8.0+
- Redis 7+
- Nginx (reverse proxy)
- SSL Certificate (Let's Encrypt recommended)

## Pre-Deployment Setup

### 1. Server Preparation

```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y curl wget git unzip software-properties-common

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installations
docker --version
docker-compose --version
```

### 2. Firewall Configuration

```bash
# Configure UFW firewall
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 3306/tcp  # MySQL (if external access needed)
sudo ufw enable
```

### 3. Domain Setup (Optional)

Configure your domain DNS to point to your VPS IP:
```
A    api.studentlink.bestlink.edu.ph    YOUR_VPS_IP
A    studentlink.bestlink.edu.ph        YOUR_VPS_IP
```

## Deployment Steps

### 1. Clone Repository

```bash
# Create application directory
sudo mkdir -p /var/www/studentlink
sudo chown $USER:$USER /var/www/studentlink
cd /var/www/studentlink

# Clone the repository
git clone https://github.com/your-repo/studentlink-backend.git .
```

### 2. Environment Configuration

```bash
# Copy environment file
cp env.example .env

# Edit environment variables
nano .env
```

**Critical Environment Variables:**

```bash
# Application
APP_NAME="StudentLink Backend"
APP_ENV=production
APP_DEBUG=false
APP_URL=https://api.studentlink.bestlink.edu.ph

# Database
DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=studentlink
DB_USERNAME=studentlink
DB_PASSWORD=your_secure_password_here

# JWT Secret (generate with: php artisan jwt:secret)
JWT_SECRET=your_jwt_secret_here

# OpenAI Configuration
OPENAI_API_KEY=your_openai_api_key_here

# Firebase Configuration
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nyour_private_key_here\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=your_firebase_client_email

# Dialogflow Configuration
DIALOGFLOW_PROJECT_ID=your_dialogflow_project_id
DIALOGFLOW_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nyour_private_key_here\n-----END PRIVATE KEY-----\n"
DIALOGFLOW_CLIENT_EMAIL=your_dialogflow_client_email

# CORS Configuration
CORS_ALLOWED_ORIGINS="https://studentlink.bestlink.edu.ph,http://localhost:3000"

# Mail Configuration
MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your_email@gmail.com
MAIL_PASSWORD=your_app_password
MAIL_ENCRYPTION=tls
```

### 3. SSL Certificate Setup

```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Generate SSL certificate
sudo certbot certonly --standalone -d api.studentlink.bestlink.edu.ph

# Create SSL directory for Docker
sudo mkdir -p /var/www/studentlink/docker/ssl
sudo cp /etc/letsencrypt/live/api.studentlink.bestlink.edu.ph/fullchain.pem /var/www/studentlink/docker/ssl/studentlink.crt
sudo cp /etc/letsencrypt/live/api.studentlink.bestlink.edu.ph/privkey.pem /var/www/studentlink/docker/ssl/studentlink.key
sudo chown $USER:$USER /var/www/studentlink/docker/ssl/*
```

### 4. Deploy with Docker Compose

```bash
# Build and start services
docker-compose up -d --build

# Verify services are running
docker-compose ps

# Check logs
docker-compose logs -f app
```

### 5. Database Setup

```bash
# Generate application key
docker-compose exec app php artisan key:generate

# Run database migrations
docker-compose exec app php artisan migrate --force

# Seed initial data
docker-compose exec app php artisan db:seed --force

# Create JWT secret
docker-compose exec app php artisan jwt:secret --force
```

### 6. Optimize Application

```bash
# Cache configuration
docker-compose exec app php artisan config:cache
docker-compose exec app php artisan route:cache
docker-compose exec app php artisan view:cache

# Create storage symlink
docker-compose exec app php artisan storage:link

# Set proper permissions
docker-compose exec app chown -R www-data:www-data storage bootstrap/cache
docker-compose exec app chmod -R 775 storage bootstrap/cache
```

## Post-Deployment Configuration

### 1. Enable HTTPS in Nginx

Update `docker/nginx/sites-available/studentlink.conf`:

```nginx
# Uncomment HTTPS server block
server {
    listen 443 ssl http2;
    server_name api.studentlink.bestlink.edu.ph;
    # ... rest of HTTPS configuration
}

# Uncomment HTTP to HTTPS redirect
server {
    listen 80;
    server_name api.studentlink.bestlink.edu.ph;
    return 301 https://$host$request_uri;
}
```

Restart Nginx:
```bash
docker-compose restart nginx
```

### 2. Setup Monitoring

```bash
# Create log rotation
sudo tee /etc/logrotate.d/studentlink << EOF
/var/www/studentlink/storage/logs/*.log {
    daily
    missingok
    rotate 14
    compress
    notifempty
    create 0644 www-data www-data
    postrotate
        docker-compose exec app php artisan cache:clear
    endscript
}
EOF
```

### 3. Backup Setup

```bash
# Create backup script
sudo tee /usr/local/bin/studentlink-backup.sh << EOF
#!/bin/bash
BACKUP_DIR="/var/backups/studentlink"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup directory
mkdir -p $BACKUP_DIR

# Database backup
docker-compose exec -T db mysqldump -u root -p$DB_PASSWORD studentlink > $BACKUP_DIR/database_$DATE.sql

# Application files backup
tar -czf $BACKUP_DIR/files_$DATE.tar.gz /var/www/studentlink --exclude=node_modules --exclude=.git

# Keep only last 7 days of backups
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete
EOF

sudo chmod +x /usr/local/bin/studentlink-backup.sh

# Setup daily backup cron
echo "0 2 * * * root /usr/local/bin/studentlink-backup.sh" | sudo tee -a /etc/crontab
```

### 4. SSL Auto-Renewal

```bash
# Test SSL renewal
sudo certbot renew --dry-run

# Setup auto-renewal cron
echo "0 12 * * * root /usr/bin/certbot renew --quiet && docker-compose restart nginx" | sudo tee -a /etc/crontab
```

## Testing the Deployment

### 1. Health Check

```bash
# Test API health endpoint
curl https://api.studentlink.bestlink.edu.ph/api/health

# Expected response:
{
    "status": "ok",
    "timestamp": "2024-01-15T10:30:00Z",
    "version": "1.0.0"
}
```

### 2. Authentication Test

```bash
# Test login endpoint
curl -X POST https://api.studentlink.bestlink.edu.ph/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@bestlink.edu.ph",
    "password": "admin123"
  }'
```

### 3. Database Connection Test

```bash
# Check database tables
docker-compose exec db mysql -u root -p$DB_PASSWORD -e "USE studentlink; SHOW TABLES;"
```

## Maintenance and Updates

### 1. Application Updates

```bash
# Pull latest changes
git pull origin main

# Rebuild and restart services
docker-compose down
docker-compose up -d --build

# Run any new migrations
docker-compose exec app php artisan migrate --force

# Clear caches
docker-compose exec app php artisan config:cache
docker-compose exec app php artisan route:cache
```

### 2. System Monitoring

```bash
# Check service status
docker-compose ps

# View logs
docker-compose logs -f app
docker-compose logs -f db
docker-compose logs -f redis

# Check resource usage
docker stats
```

### 3. Performance Optimization

```bash
# Enable OPcache in production
echo "opcache.enable=1" >> /usr/local/etc/php/conf.d/opcache.ini
echo "opcache.memory_consumption=256" >> /usr/local/etc/php/conf.d/opcache.ini

# Restart PHP container
docker-compose restart app
```

## Troubleshooting

### Common Issues

1. **Database Connection Failed**
   ```bash
   # Check database service
   docker-compose logs db
   
   # Verify credentials
   docker-compose exec db mysql -u root -p
   ```

2. **Permission Denied Errors**
   ```bash
   # Fix permissions
   docker-compose exec app chown -R www-data:www-data storage bootstrap/cache
   docker-compose exec app chmod -R 775 storage bootstrap/cache
   ```

3. **SSL Certificate Issues**
   ```bash
   # Check certificate validity
   openssl x509 -in docker/ssl/studentlink.crt -text -noout
   
   # Renew certificate
   sudo certbot renew
   ```

4. **High Memory Usage**
   ```bash
   # Check container resource usage
   docker stats
   
   # Adjust memory limits in docker-compose.yml
   ```

### Log Locations

- Application logs: `/var/www/studentlink/storage/logs/`
- Nginx logs: `/var/log/nginx/`
- System logs: `/var/log/syslog`
- Docker logs: `docker-compose logs [service]`

## Security Considerations

### 1. Server Hardening

```bash
# Disable root login
sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl restart ssh

# Install fail2ban
sudo apt install -y fail2ban
sudo systemctl enable fail2ban
```

### 2. Database Security

```bash
# Run MySQL security script
docker-compose exec db mysql_secure_installation
```

### 3. Application Security

- Regularly update dependencies: `composer update`
- Monitor security advisories
- Use strong passwords and API keys
- Enable audit logging
- Regular security scans

## Support and Resources

- **Documentation**: `/docs/` directory
- **API Documentation**: `https://api.studentlink.bestlink.edu.ph/docs`
- **Health Check**: `https://api.studentlink.bestlink.edu.ph/api/health`
- **Support Email**: support@studentlink.edu.ph

## Production Checklist

- [ ] Environment variables configured
- [ ] SSL certificate installed and auto-renewal enabled
- [ ] Database backups scheduled
- [ ] Monitoring and logging configured
- [ ] Firewall rules applied
- [ ] Domain DNS configured
- [ ] Health checks passing
- [ ] Performance optimizations applied
- [ ] Security hardening completed
- [ ] Documentation updated
