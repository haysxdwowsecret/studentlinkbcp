#!/bin/bash

# Fix Frontend Crash/Reload Issues
echo "🔧 Fixing Frontend Crash Issues..."

# Check current frontend service status
echo "=== Current Frontend Service Status ==="
systemctl status studentlink-frontend --no-pager -l

# Stop the problematic frontend service
echo "=== Stopping Frontend Service ==="
systemctl stop studentlink-frontend

# Kill any remaining Next.js processes
echo "=== Killing Remaining Next.js Processes ==="
pkill -f "next" || true
pkill -f "node.*next" || true
sleep 3

# Check what's running on port 3000
echo "=== Checking Port 3000 ==="
netstat -tlnp | grep :3000 || echo "Port 3000 is free"

# Go to frontend directory
cd /var/www/studentlink-prod/studentlink_web

# Clear Next.js cache
echo "=== Clearing Next.js Cache ==="
rm -rf .next
rm -rf node_modules/.cache

# Rebuild the frontend
echo "=== Rebuilding Frontend ==="
npm run build

# Create a more robust systemd service
echo "=== Creating Robust Frontend Service ==="
cat > /etc/systemd/system/studentlink-frontend.service << 'EOF'
[Unit]
Description=StudentLink Frontend (Next.js)
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/var/www/studentlink-prod/studentlink_web
ExecStart=/usr/bin/npm start
Restart=always
RestartSec=5
Environment=NODE_ENV=production
Environment=PORT=3000
Environment=HOSTNAME=0.0.0.0

# Resource limits
LimitNOFILE=65536
LimitNPROC=4096

# Logging
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start service
echo "=== Starting Frontend Service ==="
systemctl daemon-reload
systemctl enable studentlink-frontend
systemctl start studentlink-frontend

# Wait for service to start
sleep 10

# Check service status
echo "=== Checking Service Status ==="
systemctl status studentlink-frontend --no-pager -l

# Test the frontend
echo "=== Testing Frontend ==="
curl -I http://localhost:3000 2>/dev/null | head -1 || echo "❌ Frontend test failed"

# Check ports
echo "=== Checking Ports ==="
netstat -tlnp | grep -E "(3000|8000|80)"

echo "✅ Frontend crash fix complete!"
echo "🌐 Try accessing your site now: http://bcpstudentlink.online"
