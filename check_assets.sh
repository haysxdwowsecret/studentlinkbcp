#!/bin/bash

# Check and Fix Static Assets
echo "🔍 Checking Static Assets..."

# Check frontend public directory
echo "=== Frontend Public Directory ==="
cd /var/www/studentlink-prod/studentlink_web
ls -la public/

echo "=== Images in Public Directory ==="
find public/ -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.svg" -o -name "*.ico" \) -exec ls -la {} \;

echo "=== Next.js Static Directory ==="
ls -la .next/static/ 2>/dev/null || echo "No .next/static directory found"

# Check if images are accessible via HTTP
echo "=== Testing Image Access ==="
echo "Testing favicon:"
curl -I https://bcpstudentlink.online/favicon.ico 2>/dev/null | head -1 || echo "❌ Favicon not accessible"

echo "Testing any PNG image:"
find public/ -name "*.png" | head -1 | while read img; do
    imgname=$(basename "$img")
    echo "Testing $imgname:"
    curl -I "https://bcpstudentlink.online/$imgname" 2>/dev/null | head -1 || echo "❌ $imgname not accessible"
done

# Check nginx configuration for static files
echo "=== Nginx Static File Configuration ==="
grep -A 10 -B 5 "location.*static" /etc/nginx/sites-available/bcpstudentlink.online || echo "No static file configuration found"

# Check if there are any 404 errors in nginx logs
echo "=== Recent 404 Errors ==="
tail -50 /var/log/nginx/access.log | grep "404" | head -5 || echo "No recent 404 errors found"

echo "✅ Asset check complete!"
