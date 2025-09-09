#!/bin/bash

# StudentLink Frontend Deployment Script
# Run this script after backend deployment

set -e  # Exit on any error

echo "🚀 Starting StudentLink Frontend Deployment..."
echo "=============================================="

# Navigate to frontend directory
cd /var/www/bcpstudentlink.online/studentlink_web

# Install dependencies
echo "📦 Installing Node.js dependencies..."
npm install

# Create production environment file
echo "⚙️ Configuring production environment..."
cat > .env.local << 'EOF'
NEXT_PUBLIC_API_BASE_URL=https://bcpstudentlink.online/api
NEXT_PUBLIC_WEB_BASE_URL=https://bcpstudentlink.online

NEXT_PUBLIC_APP_NAME="StudentLink Web Portal"
NEXT_PUBLIC_COLLEGE_NAME="Bestlink College of the Philippines"

# Firebase Configuration (Add your Firebase credentials)
NEXT_PUBLIC_FIREBASE_API_KEY=
NEXT_PUBLIC_FIREBASE_PROJECT_ID=
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=
NEXT_PUBLIC_FIREBASE_APP_ID=

NEXT_PUBLIC_ENABLE_AI_FEATURES=true
NEXT_PUBLIC_ENABLE_PUSH_NOTIFICATIONS=true
NEXT_PUBLIC_ENABLE_REAL_TIME_UPDATES=true

NEXT_PUBLIC_DEBUG_MODE=false
NEXT_PUBLIC_ENABLE_MOCK_DATA=false
EOF

# Build for production
echo "🔨 Building for production..."
npm run build

# Create systemd service for Next.js
echo "👷 Creating Next.js service..."
cat > /etc/systemd/system/studentlink-web.service << 'EOF'
[Unit]
Description=StudentLink Web Portal
After=network.target

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=/var/www/bcpstudentlink.online/studentlink_web
ExecStart=/usr/bin/npm start
Restart=always
RestartSec=10
Environment=NODE_ENV=production
Environment=PORT=3000

# Logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=studentlink-web

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
echo "🔄 Starting Next.js service..."
systemctl daemon-reload
systemctl enable studentlink-web
systemctl start studentlink-web

# Wait for service to start
echo "⏳ Waiting for service to start..."
sleep 10

# Check if service is running
if systemctl is-active --quiet studentlink-web; then
    echo "✅ Next.js service is running!"
else
    echo "❌ Next.js service failed to start. Checking logs..."
    journalctl -u studentlink-web --no-pager -l
    exit 1
fi

# Test the frontend
echo "🧪 Testing frontend..."
if curl -f http://localhost:3000 > /dev/null 2>&1; then
    echo "✅ Frontend is responding correctly!"
else
    echo "⚠️ Frontend test failed. Check the service logs."
fi

# Create PM2 configuration for better process management (alternative)
echo "📋 Creating PM2 configuration (optional)..."
cat > /var/www/bcpstudentlink.online/studentlink_web/ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'studentlink-web',
    script: 'npm',
    args: 'start',
    cwd: '/var/www/bcpstudentlink.online/studentlink_web',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    }
  }]
};
EOF

# Create log rotation for Next.js
echo "📝 Setting up log rotation..."
cat > /etc/logrotate.d/studentlink-web << 'EOF'
/var/log/studentlink-web/*.log {
    daily
    missingok
    rotate 14
    compress
    notifempty
    create 644 www-data www-data
    postrotate
        systemctl reload studentlink-web
    endscript
}
EOF

# Set proper permissions
echo "🔐 Setting proper permissions..."
chown -R www-data:www-data /var/www/bcpstudentlink.online/studentlink_web
chmod -R 755 /var/www/bcpstudentlink.online/studentlink_web

# Create health check script
echo "🏥 Creating health check script..."
cat > /usr/local/bin/studentlink-health-check.sh << 'EOF'
#!/bin/bash

# StudentLink Health Check Script
echo "🏥 StudentLink Health Check - $(date)"
echo "=================================="

# Check backend API
echo "🔍 Checking Backend API..."
if curl -f -s http://localhost/api/health > /dev/null; then
    echo "✅ Backend API: OK"
else
    echo "❌ Backend API: FAILED"
fi

# Check frontend
echo "🔍 Checking Frontend..."
if curl -f -s http://localhost:3000 > /dev/null; then
    echo "✅ Frontend: OK"
else
    echo "❌ Frontend: FAILED"
fi

# Check services
echo "🔍 Checking Services..."
if systemctl is-active --quiet nginx; then
    echo "✅ Nginx: OK"
else
    echo "❌ Nginx: FAILED"
fi

if systemctl is-active --quiet php8.3-fpm; then
    echo "✅ PHP-FPM: OK"
else
    echo "❌ PHP-FPM: FAILED"
fi

if systemctl is-active --quiet studentlink-web; then
    echo "✅ Next.js: OK"
else
    echo "❌ Next.js: FAILED"
fi

if systemctl is-active --quiet mysql; then
    echo "✅ MySQL: OK"
else
    echo "❌ MySQL: FAILED"
fi

if systemctl is-active --quiet redis-server; then
    echo "✅ Redis: OK"
else
    echo "❌ Redis: FAILED"
fi

echo "=================================="
echo "🏥 Health check completed!"
EOF

chmod +x /usr/local/bin/studentlink-health-check.sh

# Run health check
echo "🏥 Running health check..."
/usr/local/bin/studentlink-health-check.sh

echo "✅ Frontend deployment completed successfully!"
echo "=============================================="
echo "📋 Frontend is now running at:"
echo "🌐 Web Portal: https://bcpstudentlink.online"
echo "🔗 API Endpoint: https://bcpstudentlink.online/api"
echo ""
echo "📝 Next steps:"
echo "1. Configure SSL certificate"
echo "2. Update Firebase credentials in .env.local"
echo "3. Test the complete system"
echo ""
echo "🔧 To update Firebase credentials, edit: /var/www/bcpstudentlink.online/studentlink_web/.env.local"
echo "🏥 To run health check: /usr/local/bin/studentlink-health-check.sh"
echo ""
echo "📊 Service Management:"
echo "• Check status: systemctl status studentlink-web"
echo "• View logs: journalctl -u studentlink-web -f"
echo "• Restart: systemctl restart studentlink-web"
