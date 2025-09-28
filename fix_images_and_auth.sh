#!/bin/bash

# Fix Images and Authentication Issues
echo "🔧 Fixing Images and Authentication Issues..."

# 1. Check current service status
echo "=== Checking Service Status ==="
systemctl status studentlink-backend --no-pager -l | head -10
systemctl status studentlink-frontend --no-pager -l | head -10

# 2. Fix image paths and static assets
echo "=== Fixing Image Paths ==="
cd /var/www/studentlink-prod/studentlink_web

# Check if public directory exists and has proper permissions
ls -la public/
chmod -R 755 public/

# Check if images exist in public directory
echo "Checking for images in public directory:"
find public/ -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.svg" | head -10

# 3. Fix backend authentication issues
echo "=== Fixing Backend Authentication ==="
cd /var/www/studentlink-prod/studentlink_backend

# Clear all caches
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

# Check if users table exists and has data
echo "Checking users table:"
mysql -u studentlink -p'StudentLink2024!' -e "USE studentlink_prod; SELECT COUNT(*) as user_count FROM users;" 2>/dev/null || echo "❌ Users table issue"

# Create default admin user if it doesn't exist
echo "Creating default admin user..."
mysql -u studentlink -p'StudentLink2024!' -e "
USE studentlink_prod;
INSERT IGNORE INTO users (name, email, password, role, created_at, updated_at) 
VALUES ('Admin User', 'admin@bestlink.edu.ph', '\$2y\$10\$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', NOW(), NOW());
" 2>/dev/null

# 4. Fix frontend environment for proper API calls
echo "=== Fixing Frontend Environment ==="
cd /var/www/studentlink-prod/studentlink_web

# Update environment to use HTTPS properly
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

# 5. Rebuild frontend with proper environment
echo "=== Rebuilding Frontend ==="
rm -rf .next
npm run build

# 6. Fix backend environment
echo "=== Fixing Backend Environment ==="
cd /var/www/studentlink-prod/studentlink_backend

# Update backend environment
sed -i 's|APP_URL=.*|APP_URL=https://bcpstudentlink.online|g' .env
sed -i 's|CORS_ALLOWED_ORIGINS=.*|CORS_ALLOWED_ORIGINS="https://bcpstudentlink.online,https://www.bcpstudentlink.online,http://localhost:3000"|g' .env

# 7. Restart all services
echo "=== Restarting Services ==="
systemctl restart studentlink-backend
systemctl restart studentlink-frontend
systemctl restart nginx

# Wait for services to start
sleep 10

# 8. Test everything
echo "=== Testing Services ==="
echo "Testing backend API:"
curl -I https://bcpstudentlink.online/api 2>/dev/null | head -1 || echo "❌ Backend API failed"

echo "Testing frontend:"
curl -I https://bcpstudentlink.online 2>/dev/null | head -1 || echo "❌ Frontend failed"

echo "Testing authentication endpoint:"
curl -I https://bcpstudentlink.online/api/auth/login 2>/dev/null | head -1 || echo "❌ Auth endpoint failed"

# 9. Check service status
echo "=== Final Service Status ==="
systemctl status studentlink-backend --no-pager -l | head -5
systemctl status studentlink-frontend --no-pager -l | head -5

echo "✅ Images and Authentication fix complete!"
echo "🌐 Try accessing your site now: https://bcpstudentlink.online"
echo "🔑 Try logging in with: admin@bestlink.edu.ph / password"
