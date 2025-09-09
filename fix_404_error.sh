#!/bin/bash

# StudentLink 404 Error Fix Script
# This script will completely fix the 404 error and routing issues

set -e

echo "🔧 StudentLink 404 Error Fix Script"
echo "===================================="

# Step 1: Check current status
echo "📊 Step 1: Checking current status..."
echo "------------------------------------"

# Check if we're in the right directory
if [ ! -d "/var/www/bcpstudentlink.online" ]; then
    echo "❌ Project directory not found. Please run this from the VPS root."
    exit 1
fi

cd /var/www/bcpstudentlink.online

# Check git status
echo "🔍 Checking git status..."
git status

# Check if changes were pulled
echo "🔍 Checking if latest changes are present..."
if git log --oneline -1 | grep -q "Fix 404 error"; then
    echo "✅ Latest routing fix is present"
else
    echo "❌ Latest routing fix not found. Pulling changes..."
    git pull origin master
fi

# Step 2: Force update frontend
echo ""
echo "📦 Step 2: Force updating frontend..."
echo "------------------------------------"

cd studentlink_web

# Clear all caches and node_modules
echo "🧹 Clearing all caches..."
rm -rf .next
rm -rf node_modules
rm -rf package-lock.json

# Reinstall dependencies
echo "📦 Reinstalling dependencies..."
npm install

# Create/update environment file
echo "⚙️ Updating environment configuration..."
cat > .env.local << 'EOF'
NEXT_PUBLIC_API_BASE_URL=https://bcpstudentlink.online/api
NEXT_PUBLIC_WEB_BASE_URL=https://bcpstudentlink.online
NEXT_PUBLIC_APP_NAME="StudentLink Web Portal"
NEXT_PUBLIC_COLLEGE_NAME="Bestlink College of the Philippines"
NEXT_PUBLIC_DEBUG_MODE=false
NEXT_PUBLIC_ENABLE_MOCK_DATA=false
EOF

# Build for production
echo "🔨 Building for production..."
npm run build

# Step 3: Fix services
echo ""
echo "👷 Step 3: Fixing services..."
echo "-----------------------------"

# Stop all services
echo "⏹️ Stopping all services..."
sudo systemctl stop studentlink-web 2>/dev/null || true
sudo systemctl stop studentlink_backend 2>/dev/null || true
sudo systemctl stop nginx 2>/dev/null || true

# Kill any remaining processes
echo "🔪 Killing any remaining processes..."
sudo pkill -f "next" 2>/dev/null || true
sudo pkill -f "npm start" 2>/dev/null || true
sudo pkill -f "artisan serve" 2>/dev/null || true

# Create/update backend service
echo "🔧 Creating backend service..."
sudo tee /etc/systemd/system/studentlink_backend.service > /dev/null << 'EOF'
[Unit]
Description=StudentLink Backend API
After=network.target mysql.service redis-server.service

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=/var/www/bcpstudentlink.online/studentlink_backend
ExecStart=/usr/bin/php artisan serve --host=0.0.0.0 --port=8000
Restart=always
RestartSec=10
Environment=APP_ENV=production
Environment=APP_DEBUG=false

# Logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=studentlink-backend

[Install]
WantedBy=multi-user.target
EOF

# Create/update frontend service
echo "🔧 Creating frontend service..."
sudo tee /etc/systemd/system/studentlink-web.service > /dev/null << 'EOF'
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

# Reload systemd
echo "🔄 Reloading systemd..."
sudo systemctl daemon-reload

# Enable services
sudo systemctl enable studentlink_backend
sudo systemctl enable studentlink-web

# Step 4: Fix Nginx configuration
echo ""
echo "🌐 Step 4: Fixing Nginx configuration..."
echo "---------------------------------------"

# Create proper Nginx configuration
sudo tee /etc/nginx/sites-available/bcpstudentlink.online > /dev/null << 'EOF'
# Redirect HTTP to HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name bcpstudentlink.online www.bcpstudentlink.online;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name bcpstudentlink.online www.bcpstudentlink.online;

    ssl_certificate /etc/letsencrypt/live/bcpstudentlink.online/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/bcpstudentlink.online/privkey.pem;
    
    # Basic SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # API proxy to Laravel backend
    location /api {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }

    # Frontend proxy to Next.js with mobile support
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Port $server_port;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
        
        # Handle Next.js routing
        try_files $uri $uri/ @nextjs;
    }

    # Next.js fallback for client-side routing
    location @nextjs {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

# Test Nginx configuration
echo "🧪 Testing Nginx configuration..."
sudo nginx -t

# Step 5: Start services in correct order
echo ""
echo "🚀 Step 5: Starting services..."
echo "------------------------------"

# Start backend first
echo "🔄 Starting backend service..."
sudo systemctl start studentlink_backend
sleep 5

# Check if backend is running
if sudo systemctl is-active --quiet studentlink_backend; then
    echo "✅ Backend service is running"
else
    echo "❌ Backend service failed to start"
    sudo journalctl -u studentlink_backend --no-pager -l
fi

# Start frontend
echo "🔄 Starting frontend service..."
sudo systemctl start studentlink-web
sleep 10

# Check if frontend is running
if sudo systemctl is-active --quiet studentlink-web; then
    echo "✅ Frontend service is running"
else
    echo "❌ Frontend service failed to start"
    sudo journalctl -u studentlink-web --no-pager -l
fi

# Start Nginx
echo "🔄 Starting Nginx..."
sudo systemctl start nginx

# Step 6: Test everything
echo ""
echo "🧪 Step 6: Testing the fix..."
echo "-----------------------------"

# Test backend API
echo "🔍 Testing backend API..."
if curl -f -s http://localhost:8000/api/health > /dev/null; then
    echo "✅ Backend API: OK"
else
    echo "❌ Backend API: FAILED"
fi

# Test frontend
echo "🔍 Testing frontend..."
if curl -f -s http://localhost:3000 > /dev/null; then
    echo "✅ Frontend: OK"
else
    echo "❌ Frontend: FAILED"
fi

# Test public access
echo "🔍 Testing public access..."
if curl -f -s https://bcpstudentlink.online > /dev/null; then
    echo "✅ Public HTTPS: OK"
else
    echo "❌ Public HTTPS: FAILED"
fi

# Test login route specifically
echo "🔍 Testing login route..."
if curl -f -s https://bcpstudentlink.online/login > /dev/null; then
    echo "✅ Login route: OK"
else
    echo "❌ Login route: FAILED"
fi

# Step 7: Clear all caches
echo ""
echo "🧹 Step 7: Clearing all caches..."
echo "--------------------------------"

# Clear browser caches (instructions)
echo "📝 To clear browser caches:"
echo "• Chrome/Edge: Ctrl+Shift+Delete"
echo "• Firefox: Ctrl+Shift+Delete"
echo "• Mobile: Clear browser data in settings"

# Clear server caches
echo "🧹 Clearing server caches..."
sudo systemctl restart nginx
sudo systemctl restart studentlink-web
sudo systemctl restart studentlink_backend

echo ""
echo "✅ 404 Error Fix Script Completed!"
echo "=================================="
echo ""
echo "📋 What was fixed:"
echo "• Updated frontend with latest routing changes"
echo "• Recreated all services with proper configuration"
echo "• Fixed Nginx configuration for proper routing"
echo "• Cleared all caches and rebuilt the application"
echo ""
echo "🌐 Test your site now:"
echo "• https://bcpstudentlink.online"
echo "• https://bcpstudentlink.online/login"
echo ""
echo "📊 Check service status:"
echo "• sudo systemctl status studentlink-web"
echo "• sudo systemctl status studentlink_backend"
echo "• sudo systemctl status nginx"
echo ""
echo "📝 If issues persist, check logs:"
echo "• sudo journalctl -u studentlink-web -f"
echo "• sudo journalctl -u studentlink_backend -f"
echo "• sudo tail -f /var/log/nginx/error.log"
