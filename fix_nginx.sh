#!/bin/bash

# Fix Nginx Configuration Script
echo "🔧 Fixing Nginx Configuration..."

# Copy the configuration file
cp nginx-bcpstudentlink.conf /etc/nginx/sites-available/bcpstudentlink.online

# Enable the site
ln -sf /etc/nginx/sites-available/bcpstudentlink.online /etc/nginx/sites-enabled/

# Test Nginx configuration
nginx -t

# Reload Nginx
systemctl reload nginx

# Check if it's working
echo "Testing the site..."
curl -I http://bcpstudentlink.online

echo "✅ Nginx configuration fixed!"
echo "🌐 Your site should now be accessible at: http://bcpstudentlink.online"
