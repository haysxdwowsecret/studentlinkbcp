#!/bin/bash

# Fix Client Access Issues
echo "🔧 Fixing Client Access Issues..."

# 1. Check if there are multiple nginx configurations conflicting
echo "=== Checking for conflicting nginx configs ==="
ls -la /etc/nginx/sites-enabled/

# 2. Remove default nginx site that might be interfering
echo "=== Removing default nginx site ==="
rm -f /etc/nginx/sites-enabled/default

# 3. Ensure our site config is properly set up
echo "=== Ensuring proper site configuration ==="
cat > /etc/nginx/sites-available/bcpstudentlink.online << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name bcpstudentlink.online www.bcpstudentlink.online _;
    
    # Frontend (Next.js)
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 86400;
    }
    
    # Backend API
    location /api {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 86400;
    }
}
EOF

# 4. Enable the site
ln -sf /etc/nginx/sites-available/bcpstudentlink.online /etc/nginx/sites-enabled/

# 5. Test and reload nginx
nginx -t
systemctl reload nginx

# 6. Check what's listening
echo "=== Checking listening ports ==="
netstat -tlnp | grep :80

# 7. Test access
echo "=== Testing access ==="
curl -I http://localhost
curl -I http://72.60.107.248

echo "✅ Client access configuration updated!"
echo "🌐 Try these URLs:"
echo "   http://bcpstudentlink.online"
echo "   http://72.60.107.248"
echo "   http://www.bcpstudentlink.online"
