#!/bin/bash

# Update environment files to use HTTPS
echo "🔒 Updating environment files to use HTTPS..."

# Update backend .env file
echo "Updating backend environment..."
cd /var/www/studentlink-prod/studentlink_backend

# Update APP_URL to HTTPS
sed -i 's|APP_URL=http://|APP_URL=https://|g' .env
sed -i 's|APP_URL=https://127.0.0.1:8000|APP_URL=https://bcpstudentlink.online|g' .env

# Update CORS origins to include HTTPS
sed -i 's|CORS_ALLOWED_ORIGINS=.*|CORS_ALLOWED_ORIGINS="https://bcpstudentlink.online,https://www.bcpstudentlink.online,http://localhost:3000,http://localhost:3001"|g' .env

# Update web frontend environment
echo "Updating frontend environment..."
cd /var/www/studentlink-prod/studentlink_web

# Update API base URL to HTTPS
sed -i 's|NEXT_PUBLIC_API_BASE_URL=http://|NEXT_PUBLIC_API_BASE_URL=https://|g' .env.production
sed -i 's|NEXT_PUBLIC_API_BASE_URL=https://localhost:8000/api|NEXT_PUBLIC_API_BASE_URL=https://bcpstudentlink.online/api|g' .env.production

# Clear Laravel caches
echo "Clearing Laravel caches..."
cd /var/www/studentlink-prod/studentlink_backend
php artisan config:clear
php artisan cache:clear
php artisan route:clear

# Restart services
echo "Restarting services..."
systemctl restart studentlink-backend
systemctl restart studentlink-frontend

echo "✅ Environment files updated to use HTTPS!"
echo "🔒 All API calls will now use HTTPS"
