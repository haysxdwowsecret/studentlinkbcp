# StudentLink Deployment Guide - Hostinger VPS

## 🎯 Deployment Overview

This guide will help you deploy the complete StudentLink ecosystem to your Hostinger VPS running Ubuntu 24.04 LTS.

### Your VPS Details
- **Server**: Malaysia - Kuala Lumpur
- **OS**: Ubuntu 24.04 LTS
- **Hostname**: srv988639.hstgr.cloud
- **IP**: 72.60.107.248
- **Domain**: bcpstudentlink.online
- **SSH**: root@srv988639.hstgr.cloud

---

## 🚀 Step-by-Step Deployment Process

### Step 1: Connect to Your VPS

```bash
# SSH into your VPS
ssh root@srv988639.hstgr.cloud

# Update system packages
apt update && apt upgrade -y
```

### Step 2: Install Required Software

```bash
# Install LEMP stack (Nginx, MySQL, PHP, Composer)
apt install -y nginx mysql-server php8.3-fpm php8.3-mysql php8.3-xml php8.3-mbstring php8.3-curl php8.3-zip php8.3-bcmath php8.3-gd php8.3-intl php8.3-cli php8.3-common php8.3-opcache php8.3-readline php8.3-sqlite3 php8.3-tokenizer php8.3-xmlrpc php8.3-xsl php8.3-json php8.3-redis

# Install Composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# Install Node.js 18.x
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
apt install -y nodejs

# Install Git
apt install -y git

# Install Redis (optional, for caching)
apt install -y redis-server

# Install Certbot for SSL
apt install -y certbot python3-certbot-nginx
```

### Step 3: Configure MySQL Database

```bash
# Secure MySQL installation
mysql_secure_installation

# Create database and user
mysql -u root -p
```

```sql
-- In MySQL console
CREATE DATABASE studentlink_prod;
CREATE USER 'studentlink_user'@'localhost' IDENTIFIED BY 'your_secure_password';
GRANT ALL PRIVILEGES ON studentlink_prod.* TO 'studentlink_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### Step 4: Configure Nginx

```bash
# Create Nginx configuration for your domain
nano /etc/nginx/sites-available/bcpstudentlink.online
```

```nginx
# Nginx configuration for bcpstudentlink.online
server {
    listen 80;
    server_name bcpstudentlink.online www.bcpstudentlink.online;
    root /var/www/bcpstudentlink.online/public;
    index index.php index.html index.htm;

    # Main application (Next.js frontend)
    location / {
        try_files $uri $uri/ @frontend;
    }

    # API routes (Laravel backend)
    location /api {
        try_files $uri $uri/ /index.php?$query_string;
    }

    # Laravel backend
    location @frontend {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # PHP processing for Laravel
    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private must-revalidate auth;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/javascript;
}
```

```bash
# Enable the site
ln -s /etc/nginx/sites-available/bcpstudentlink.online /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default

# Test Nginx configuration
nginx -t

# Restart Nginx
systemctl restart nginx
systemctl enable nginx
```

### Step 5: Deploy Laravel Backend

```bash
# Create project directory
mkdir -p /var/www/bcpstudentlink.online
cd /var/www/bcpstudentlink.online

# Clone your repository
git clone https://github.com/haysxdwowsecret/studentlinkbcp.git .

# Navigate to backend
cd studentlink_backend

# Install PHP dependencies
composer install --optimize-autoloader --no-dev

# Install Node.js dependencies
npm install

# Copy environment file
cp .env.example .env

# Generate application key
php artisan key:generate

# Configure environment variables
nano .env
```

```bash
# Production .env configuration
APP_NAME="StudentLink Backend"
APP_ENV=production
APP_KEY=base64:your_generated_key
APP_DEBUG=false
APP_URL=https://bcpstudentlink.online

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=error

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=studentlink_prod
DB_USERNAME=studentlink_user
DB_PASSWORD=your_secure_password

BROADCAST_DRIVER=log
CACHE_DRIVER=redis
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=redis
SESSION_LIFETIME=120

MEMCACHED_HOST=127.0.0.1

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your_email@gmail.com
MAIL_PASSWORD=your_app_password
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS="noreply@bcpstudentlink.online"
MAIL_FROM_NAME="${APP_NAME}"

AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=
AWS_USE_PATH_STYLE_ENDPOINT=false

PUSHER_APP_ID=
PUSHER_APP_KEY=
PUSHER_APP_SECRET=
PUSHER_HOST=
PUSHER_PORT=443
PUSHER_SCHEME=https
PUSHER_APP_CLUSTER=mt1

VITE_PUSHER_APP_KEY="${PUSHER_APP_KEY}"
VITE_PUSHER_HOST="${PUSHER_HOST}"
VITE_PUSHER_PORT="${PUSHER_PORT}"
VITE_PUSHER_SCHEME="${PUSHER_SCHEME}"
VITE_PUSHER_APP_CLUSTER="${PUSHER_APP_CLUSTER}"

# JWT Configuration
JWT_SECRET=your_jwt_secret_here
JWT_TTL=60
JWT_REFRESH_TTL=20160

# OpenAI Configuration
OPENAI_API_KEY=your_openai_api_key

# Firebase Configuration
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_PRIVATE_KEY="your_firebase_private_key"
FIREBASE_CLIENT_EMAIL=your_firebase_client_email
```

```bash
# Run database migrations
php artisan migrate --force

# Seed database with initial data
php artisan db:seed --force

# Optimize for production
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Set proper permissions
chown -R www-data:www-data /var/www/bcpstudentlink.online
chmod -R 755 /var/www/bcpstudentlink.online
chmod -R 775 /var/www/bcpstudentlink.online/storage
chmod -R 775 /var/www/bcpstudentlink.online/bootstrap/cache
```

### Step 6: Deploy Next.js Frontend

```bash
# Navigate to frontend directory
cd /var/www/bcpstudentlink.online/studentlink_web

# Install dependencies
npm install

# Build for production
npm run build

# Create environment file
cp .env.example .env.local
nano .env.local
```

```bash
# Production .env.local configuration
NEXT_PUBLIC_API_BASE_URL=https://bcpstudentlink.online/api
NEXT_PUBLIC_WEB_BASE_URL=https://bcpstudentlink.online

NEXT_PUBLIC_APP_NAME="StudentLink Web Portal"
NEXT_PUBLIC_COLLEGE_NAME="Bestlink College of the Philippines"

NEXT_PUBLIC_FIREBASE_API_KEY=your_firebase_api_key
NEXT_PUBLIC_FIREBASE_PROJECT_ID=your_firebase_project_id
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
NEXT_PUBLIC_FIREBASE_APP_ID=your_app_id

NEXT_PUBLIC_ENABLE_AI_FEATURES=true
NEXT_PUBLIC_ENABLE_PUSH_NOTIFICATIONS=true
NEXT_PUBLIC_ENABLE_REAL_TIME_UPDATES=true

NEXT_PUBLIC_DEBUG_MODE=false
NEXT_PUBLIC_ENABLE_MOCK_DATA=false
```

```bash
# Create systemd service for Next.js
nano /etc/systemd/system/studentlink-web.service
```

```ini
[Unit]
Description=StudentLink Web Portal
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/bcpstudentlink.online/studentlink_web
ExecStart=/usr/bin/npm start
Restart=always
RestartSec=10
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
```

```bash
# Enable and start the service
systemctl daemon-reload
systemctl enable studentlink-web
systemctl start studentlink-web
```

### Step 7: Configure SSL Certificate

```bash
# Obtain SSL certificate
certbot --nginx -d bcpstudentlink.online -d www.bcpstudentlink.online

# Test automatic renewal
certbot renew --dry-run
```

### Step 8: Configure Firewall

```bash
# Configure UFW firewall
ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw --force enable
```

### Step 9: Set Up Monitoring

```bash
# Install monitoring tools
apt install -y htop iotop nethogs

# Create log rotation
nano /etc/logrotate.d/studentlink
```

```bash
# Log rotation configuration
/var/www/bcpstudentlink.online/storage/logs/*.log {
    daily
    missingok
    rotate 14
    compress
    notifempty
    create 644 www-data www-data
}
```

---

## 🔧 Post-Deployment Configuration

### 1. Test Your Deployment

```bash
# Test API endpoint
curl https://bcpstudentlink.online/api/health

# Test web portal
curl https://bcpstudentlink.online
```

### 2. Update Mobile App Configuration

Update your Flutter mobile app to use the production API:

```dart
// In your Flutter app configuration
API_BASE_URL=https://bcpstudentlink.online/api
```

### 3. Configure Domain DNS

Make sure your domain `bcpstudentlink.online` points to your VPS IP `72.60.107.248`:

```
A Record: bcpstudentlink.online -> 72.60.107.248
CNAME: www.bcpstudentlink.online -> bcpstudentlink.online
```

---

## 🚨 Troubleshooting

### Common Issues and Solutions

**1. Nginx 502 Bad Gateway**
```bash
# Check if PHP-FPM is running
systemctl status php8.3-fpm
systemctl restart php8.3-fpm
```

**2. Database Connection Issues**
```bash
# Check MySQL status
systemctl status mysql
mysql -u studentlink_user -p studentlink_prod
```

**3. Next.js Service Not Starting**
```bash
# Check service status
systemctl status studentlink-web
journalctl -u studentlink-web -f
```

**4. SSL Certificate Issues**
```bash
# Renew certificate
certbot renew --force-renewal
systemctl reload nginx
```

---

## 📊 Monitoring and Maintenance

### Daily Tasks
- Check server status: `systemctl status nginx mysql php8.3-fpm studentlink-web`
- Monitor disk space: `df -h`
- Check logs: `tail -f /var/log/nginx/error.log`

### Weekly Tasks
- Update system packages: `apt update && apt upgrade`
- Check SSL certificate expiry: `certbot certificates`
- Review application logs

### Monthly Tasks
- Database backup
- Security updates
- Performance optimization review

---

## 🔒 Security Checklist

- [ ] Firewall configured (UFW)
- [ ] SSL certificate installed
- [ ] Database secured with strong passwords
- [ ] File permissions set correctly
- [ ] Regular security updates enabled
- [ ] Log monitoring configured
- [ ] Backup strategy implemented

---

## 📞 Support

If you encounter any issues during deployment:

1. Check the logs: `/var/log/nginx/error.log`
2. Verify service status: `systemctl status [service-name]`
3. Test connectivity: `curl -I https://bcpstudentlink.online`
4. Review this guide for troubleshooting steps

---

**Your StudentLink system will be live at: https://bcpstudentlink.online**

**API Endpoint: https://bcpstudentlink.online/api**

**Mobile App API: https://bcpstudentlink.online/api**
