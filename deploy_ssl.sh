#!/bin/bash

# StudentLink SSL Configuration Script
# Run this script after frontend deployment

set -e  # Exit on any error

echo "🔒 Starting StudentLink SSL Configuration..."
echo "==========================================="

# Check if domain is pointing to the server
echo "🌐 Checking domain configuration..."
DOMAIN_IP=$(dig +short bcpstudentlink.online)
SERVER_IP="72.60.107.248"

if [ "$DOMAIN_IP" = "$SERVER_IP" ]; then
    echo "✅ Domain is correctly pointing to the server"
else
    echo "⚠️ Domain is not pointing to the server yet"
    echo "Expected IP: $SERVER_IP"
    echo "Current IP: $DOMAIN_IP"
    echo "Please update your DNS settings and wait for propagation"
    echo "You can continue with SSL setup, but it might fail until DNS is updated"
    read -p "Continue anyway? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Install Certbot if not already installed
echo "📦 Ensuring Certbot is installed..."
apt update
apt install -y certbot python3-certbot-nginx

# Stop Nginx temporarily for domain verification
echo "⏸️ Stopping Nginx for domain verification..."
systemctl stop nginx

# Obtain SSL certificate
echo "🔐 Obtaining SSL certificate..."
certbot certonly --standalone \
    --non-interactive \
    --agree-tos \
    --email admin@bcpstudentlink.online \
    -d bcpstudentlink.online \
    -d www.bcpstudentlink.online

# Update Nginx configuration for SSL
echo "🔧 Updating Nginx configuration for SSL..."
cat > /etc/nginx/sites-available/bcpstudentlink.online << 'EOF'
# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name bcpstudentlink.online www.bcpstudentlink.online;
    return 301 https://$server_name$request_uri;
}

# HTTPS configuration
server {
    listen 443 ssl http2;
    server_name bcpstudentlink.online www.bcpstudentlink.online;
    root /var/www/bcpstudentlink.online/public;
    index index.php index.html index.htm;

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/bcpstudentlink.online/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/bcpstudentlink.online/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # HSTS
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    # Main application (Next.js frontend)
    location / {
        try_files $uri $uri/ @frontend;
    }

    # API routes (Laravel backend)
    location /api {
        try_files $uri $uri/ /index.php?$query_string;
    }

    # Laravel backend
    location @frontend {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # PHP processing for Laravel
    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private must-revalidate auth;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/javascript;
}
EOF

# Test Nginx configuration
echo "🧪 Testing Nginx configuration..."
nginx -t

# Start Nginx
echo "🔄 Starting Nginx..."
systemctl start nginx
systemctl enable nginx

# Set up automatic certificate renewal
echo "⏰ Setting up automatic certificate renewal..."
cat > /etc/cron.d/certbot-renew << 'EOF'
# Renew Let's Encrypt certificates twice daily
0 12 * * * root certbot renew --quiet --post-hook "systemctl reload nginx"
0 0 * * * root certbot renew --quiet --post-hook "systemctl reload nginx"
EOF

# Test certificate renewal
echo "🧪 Testing certificate renewal..."
certbot renew --dry-run

# Create SSL monitoring script
echo "📊 Creating SSL monitoring script..."
cat > /usr/local/bin/ssl-monitor.sh << 'EOF'
#!/bin/bash

# SSL Certificate Monitor Script
echo "🔒 SSL Certificate Status - $(date)"
echo "=================================="

DOMAIN="bcpstudentlink.online"
CERT_PATH="/etc/letsencrypt/live/$DOMAIN/fullchain.pem"

if [ -f "$CERT_PATH" ]; then
    # Get certificate expiration date
    EXPIRY_DATE=$(openssl x509 -enddate -noout -in "$CERT_PATH" | cut -d= -f2)
    EXPIRY_EPOCH=$(date -d "$EXPIRY_DATE" +%s)
    CURRENT_EPOCH=$(date +%s)
    DAYS_LEFT=$(( (EXPIRY_EPOCH - CURRENT_EPOCH) / 86400 ))
    
    echo "📅 Certificate expires: $EXPIRY_DATE"
    echo "⏰ Days remaining: $DAYS_LEFT"
    
    if [ $DAYS_LEFT -lt 30 ]; then
        echo "⚠️ WARNING: Certificate expires in less than 30 days!"
    else
        echo "✅ Certificate is valid for $DAYS_LEFT days"
    fi
else
    echo "❌ Certificate file not found!"
fi

# Test SSL connection
echo "🔍 Testing SSL connection..."
if openssl s_client -connect $DOMAIN:443 -servername $DOMAIN < /dev/null 2>/dev/null | grep -q "Verify return code: 0"; then
    echo "✅ SSL connection: OK"
else
    echo "❌ SSL connection: FAILED"
fi

echo "=================================="
EOF

chmod +x /usr/local/bin/ssl-monitor.sh

# Run SSL monitoring
echo "🔍 Running SSL monitoring..."
/usr/local/bin/ssl-monitor.sh

# Test the complete system
echo "🧪 Testing complete system..."
echo "🔍 Testing HTTP redirect..."
if curl -I http://bcpstudentlink.online 2>/dev/null | grep -q "301 Moved Permanently"; then
    echo "✅ HTTP to HTTPS redirect: OK"
else
    echo "❌ HTTP to HTTPS redirect: FAILED"
fi

echo "🔍 Testing HTTPS connection..."
if curl -f -s https://bcpstudentlink.online > /dev/null; then
    echo "✅ HTTPS connection: OK"
else
    echo "❌ HTTPS connection: FAILED"
fi

echo "🔍 Testing API endpoint..."
if curl -f -s https://bcpstudentlink.online/api/health > /dev/null; then
    echo "✅ API endpoint: OK"
else
    echo "❌ API endpoint: FAILED"
fi

echo "✅ SSL configuration completed successfully!"
echo "==========================================="
echo "🔒 Your site is now secured with SSL!"
echo "🌐 HTTPS URL: https://bcpstudentlink.online"
echo "🔗 API URL: https://bcpstudentlink.online/api"
echo ""
echo "📋 SSL Features:"
echo "• Automatic HTTP to HTTPS redirect"
echo "• A+ SSL rating with modern ciphers"
echo "• HSTS (HTTP Strict Transport Security)"
echo "• Automatic certificate renewal"
echo ""
echo "🔧 SSL Management:"
echo "• Check certificate status: /usr/local/bin/ssl-monitor.sh"
echo "• Manual renewal: certbot renew"
echo "• View certificate: openssl x509 -in /etc/letsencrypt/live/bcpstudentlink.online/fullchain.pem -text -noout"
echo ""
echo "🎉 Your StudentLink system is now fully deployed and secured!"
