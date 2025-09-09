#!/bin/bash

# StudentLink Backend Deployment Script
# Run this script after server setup

set -e  # Exit on any error

echo "🚀 Starting StudentLink Backend Deployment..."
echo "============================================="

# Navigate to project directory
cd /var/www/bcpstudentlink.online

# Clone repository if not exists
if [ ! -d "studentlink_backend" ]; then
    echo "📥 Cloning repository..."
    git clone https://github.com/haysxdwowsecret/studentlinkbcp.git .
fi

# Navigate to backend directory
cd studentlink_backend

# Install PHP dependencies
echo "📦 Installing PHP dependencies..."
composer install --optimize-autoloader --no-dev --no-interaction

# Install Node.js dependencies
echo "📱 Installing Node.js dependencies..."
npm install --production

# Copy environment file
echo "⚙️ Configuring environment..."
if [ ! -f ".env" ]; then
    cp .env.example .env
fi

# Generate application key
echo "🔑 Generating application key..."
php artisan key:generate

# Configure production environment
echo "🔧 Configuring production environment..."
cat > .env << 'EOF'
APP_NAME="StudentLink Backend"
APP_ENV=production
APP_KEY=
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
DB_PASSWORD=hellnoway@2025

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
MAIL_USERNAME=
MAIL_PASSWORD=
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
JWT_SECRET=StudentLinkJWTSecret2024Production
JWT_TTL=60
JWT_REFRESH_TTL=20160

# OpenAI Configuration (Add your API key)
OPENAI_API_KEY=

# Firebase Configuration (Add your Firebase credentials)
FIREBASE_PROJECT_ID=
FIREBASE_PRIVATE_KEY=
FIREBASE_CLIENT_EMAIL=
EOF

# Generate new application key
php artisan key:generate

# Run database migrations
echo "🗄️ Running database migrations..."
php artisan migrate --force

# Seed database with initial data
echo "🌱 Seeding database..."
php artisan db:seed --force

# Clear and cache configuration
echo "⚡ Optimizing for production..."
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

php artisan config:cache
php artisan route:cache
php artisan view:cache

# Set proper permissions
echo "🔐 Setting proper permissions..."
chown -R www-data:www-data /var/www/bcpstudentlink.online
chmod -R 755 /var/www/bcpstudentlink.online
chmod -R 775 /var/www/bcpstudentlink.online/storage
chmod -R 775 /var/www/bcpstudentlink.online/bootstrap/cache

# Create Laravel queue worker service
echo "👷 Creating queue worker service..."
cat > /etc/systemd/system/studentlink-queue.service << 'EOF'
[Unit]
Description=StudentLink Queue Worker
After=network.target

[Service]
User=www-data
Group=www-data
Restart=always
ExecStart=/usr/bin/php /var/www/bcpstudentlink.online/studentlink_backend/artisan queue:work --sleep=3 --tries=3 --max-time=3600
WorkingDirectory=/var/www/bcpstudentlink.online/studentlink_backend

[Install]
WantedBy=multi-user.target
EOF

# Enable and start queue worker
systemctl daemon-reload
systemctl enable studentlink-queue
systemctl start studentlink-queue

# Create Laravel scheduler cron job
echo "⏰ Setting up Laravel scheduler..."
(crontab -u www-data -l 2>/dev/null; echo "* * * * * cd /var/www/bcpstudentlink.online/studentlink_backend && php artisan schedule:run >> /dev/null 2>&1") | crontab -u www-data -

# Test the API
echo "🧪 Testing API endpoint..."
if curl -f http://localhost/api/health > /dev/null 2>&1; then
    echo "✅ API is responding correctly!"
else
    echo "⚠️ API test failed. Check the configuration."
fi

echo "✅ Backend deployment completed successfully!"
echo "============================================="
echo "📋 Backend is now running at:"
echo "🔗 API Base URL: https://bcpstudentlink.online/api"
echo "🧪 Health Check: https://bcpstudentlink.online/api/health"
echo ""
echo "📝 Next steps:"
echo "1. Update your .env file with actual API keys (OpenAI, Firebase, etc.)"
echo "2. Run the frontend deployment script"
echo "3. Configure SSL certificate"
echo ""
echo "🔧 To update API keys, edit: /var/www/bcpstudentlink.online/studentlink_backend/.env"
