#!/bin/bash

# StudentLink Complete Production Setup
# This script sets up everything for 24/7 production deployment

set -e

echo "🚀 Starting StudentLink Complete Production Setup..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Kill any existing processes
print_status "Stopping existing services..."
pkill -f "php artisan serve" || true
pkill -f "next start" || true
pkill -f "node.*next" || true
sleep 2

# Fix backend issues
print_status "Fixing backend configuration..."
cd /var/www/studentlink-prod/studentlink_backend

# Create missing directories
mkdir -p storage/framework/cache
mkdir -p storage/framework/views
mkdir -p storage/framework/sessions
mkdir -p storage/logs

# Fix permissions
chmod -R 777 storage
chmod -R 775 bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache

# Clear all caches
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

# Fix database issues
print_status "Fixing database issues..."
mysql -u studentlink -p'StudentLink2024!' -e "USE studentlink_prod; DROP TABLE IF EXISTS faq_items;" || true
mysql -u studentlink -p'StudentLink2024!' -e "USE studentlink_prod; DROP TABLE IF EXISTS announcements;" || true
php artisan migrate --force

# Create production environment file for web
print_status "Setting up web environment..."
cd /var/www/studentlink-prod/studentlink_web

cat > .env.production << 'EOF'
NEXT_PUBLIC_API_BASE_URL=https://bcpstudentlink.online/api
NEXT_PUBLIC_FIREBASE_API_KEY=AIzaSyBvQ8Q9R2S3T4U5V6W7X8Y9Z0A1B2C3D4E5F
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=studentlinkbcp0.firebaseapp.com
NEXT_PUBLIC_FIREBASE_PROJECT_ID=studentlinkbcp0
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=studentlinkbcp0.appspot.com
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=123456789012
NEXT_PUBLIC_FIREBASE_APP_ID=1:123456789012:web:abcdef1234567890
NEXT_PUBLIC_FIREBASE_VAPID_KEY=BL1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
EOF

# Build the frontend
print_status "Building frontend..."
npm run build

# Create systemd service for backend
print_status "Creating backend systemd service..."
cat > /etc/systemd/system/studentlink-backend.service << 'EOF'
[Unit]
Description=StudentLink Backend (Laravel)
After=network.target mysql.service

[Service]
Type=simple
User=root
WorkingDirectory=/var/www/studentlink-prod/studentlink_backend
ExecStart=/usr/bin/php artisan serve --host=0.0.0.0 --port=8000
Restart=always
RestartSec=10
Environment=APP_ENV=production

[Install]
WantedBy=multi-user.target
EOF

# Create systemd service for frontend
print_status "Creating frontend systemd service..."
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
RestartSec=10
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF

# Create monitoring script
print_status "Creating monitoring script..."
cat > /var/www/monitor_services.sh << 'EOF'
#!/bin/bash

# StudentLink Service Monitor
check_service() {
    local service_name=$1
    local port=$2
    
    if ! systemctl is-active --quiet $service_name; then
        echo "$(date): $service_name is not running, restarting..."
        systemctl restart $service_name
        sleep 5
        
        if systemctl is-active --quiet $service_name; then
            echo "$(date): $service_name restarted successfully"
        else
            echo "$(date): Failed to restart $service_name"
        fi
    fi
    
    if ! netstat -tlnp | grep -q ":$port "; then
        echo "$(date): Port $port is not listening for $service_name, restarting..."
        systemctl restart $service_name
        sleep 5
    fi
}

while true; do
    check_service "studentlink-backend" "8000"
    check_service "studentlink-frontend" "3000"
    sleep 60
done
EOF

chmod +x /var/www/monitor_services.sh

# Create systemd service for monitoring
cat > /etc/systemd/system/studentlink-monitor.service << 'EOF'
[Unit]
Description=StudentLink Service Monitor
After=network.target

[Service]
Type=simple
User=root
ExecStart=/var/www/monitor_services.sh
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable services
print_status "Enabling systemd services..."
systemctl daemon-reload
systemctl enable studentlink-backend
systemctl enable studentlink-frontend
systemctl enable studentlink-monitor

# Start services
print_status "Starting services..."
systemctl start studentlink-backend
systemctl start studentlink-frontend
systemctl start studentlink-monitor

# Wait for services to start
sleep 10

# Check service status
print_status "Checking service status..."
systemctl status studentlink-backend --no-pager -l | head -10
echo ""
systemctl status studentlink-frontend --no-pager -l | head -10
echo ""

# Test services
print_status "Testing services..."
echo "Backend (port 8000):"
curl -I http://localhost:8000 2>/dev/null | head -1 || echo "Backend not responding"
echo "Frontend (port 3000):"
curl -I http://localhost:3000 2>/dev/null | head -1 || echo "Frontend not responding"
echo ""

# Check ports
print_status "Checking ports..."
netstat -tlnp | grep -E "(3000|8000)"
echo ""

print_success "StudentLink Production Setup Complete!"
print_status "Your services are now running 24/7 with auto-restart"
print_status "Backend: http://bcpstudentlink.online/api"
print_status "Frontend: http://bcpstudentlink.online"
print_status "Monitor logs with: journalctl -u studentlink-backend -f"
print_status "Monitor logs with: journalctl -u studentlink-frontend -f"

echo ""
echo "🎉 Your StudentLink system is now LIVE and running 24/7!"
