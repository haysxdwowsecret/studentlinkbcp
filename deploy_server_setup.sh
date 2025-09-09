#!/bin/bash

# StudentLink Server Setup Script for Ubuntu 24.04 LTS
# Run this script on your Hostinger VPS

set -e  # Exit on any error

echo "🚀 Starting StudentLink Server Setup..."
echo "========================================"

# Update system packages
echo "📦 Updating system packages..."
apt update && apt upgrade -y

# Install LEMP stack
echo "🔧 Installing LEMP stack (Nginx, MySQL, PHP, Composer)..."
apt install -y nginx mysql-server php8.3-fpm php8.3-mysql php8.3-xml php8.3-mbstring php8.3-curl php8.3-zip php8.3-bcmath php8.3-gd php8.3-intl php8.3-cli php8.3-common php8.3-opcache php8.3-readline php8.3-sqlite3 php8.3-tokenizer php8.3-xmlrpc php8.3-xsl php8.3-json php8.3-redis

# Install Composer
echo "🎼 Installing Composer..."
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer

# Install Node.js 18.x
echo "📱 Installing Node.js 18.x..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
apt install -y nodejs

# Install additional tools
echo "🛠️ Installing additional tools..."
apt install -y git curl wget unzip htop iotop nethogs

# Install Redis
echo "🔴 Installing Redis..."
apt install -y redis-server
systemctl enable redis-server
systemctl start redis-server

# Install Certbot for SSL
echo "🔒 Installing Certbot for SSL..."
apt install -y certbot python3-certbot-nginx

# Configure MySQL
echo "🗄️ Configuring MySQL..."
systemctl enable mysql
systemctl start mysql

# Create MySQL database and user
echo "👤 Creating MySQL database and user..."
mysql -e "CREATE DATABASE IF NOT EXISTS studentlink_prod;"
mysql -e "CREATE USER IF NOT EXISTS 'studentlink_user'@'localhost' IDENTIFIED BY 'hellnoway@2025';"
mysql -e "GRANT ALL PRIVILEGES ON studentlink_prod.* TO 'studentlink_user'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# Configure PHP
echo "🐘 Configuring PHP..."
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/' /etc/php/8.3/fpm/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 100M/' /etc/php/8.3/fpm/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/' /etc/php/8.3/fpm/php.ini
sed -i 's/memory_limit = 128M/memory_limit = 512M/' /etc/php/8.3/fpm/php.ini

# Restart PHP-FPM
systemctl restart php8.3-fpm

# Configure Nginx
echo "🌐 Configuring Nginx..."
cat > /etc/nginx/sites-available/bcpstudentlink.online << 'EOF'
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
EOF

# Enable the site
ln -sf /etc/nginx/sites-available/bcpstudentlink.online /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
nginx -t

# Start and enable services
echo "🔄 Starting and enabling services..."
systemctl enable nginx
systemctl restart nginx
systemctl enable php8.3-fpm
systemctl restart php8.3-fpm

# Configure firewall
echo "🔥 Configuring firewall..."
ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw --force enable

# Create project directory
echo "📁 Creating project directory..."
mkdir -p /var/www/bcpstudentlink.online
chown -R www-data:www-data /var/www/bcpstudentlink.online

# Create log rotation
echo "📝 Setting up log rotation..."
cat > /etc/logrotate.d/studentlink << 'EOF'
/var/www/bcpstudentlink.online/storage/logs/*.log {
    daily
    missingok
    rotate 14
    compress
    notifempty
    create 644 www-data www-data
}
EOF

echo "✅ Server setup completed successfully!"
echo "========================================"
echo "📋 Next steps:"
echo "1. Clone your repository: cd /var/www/bcpstudentlink.online && git clone https://github.com/haysxdwowsecret/studentlinkbcp.git ."
echo "2. Run the backend deployment script"
echo "3. Run the frontend deployment script"
echo "4. Configure SSL certificate"
echo ""
echo "🌐 Your server is ready for deployment!"
echo "📧 Domain: bcpstudentlink.online"
echo "🔗 IP: 72.60.107.248"
