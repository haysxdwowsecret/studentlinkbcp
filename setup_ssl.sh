#!/bin/bash

# Setup SSL Certificate with Let's Encrypt
echo "🔒 Setting up SSL Certificate..."

# Install certbot if not already installed
echo "Installing certbot..."
apt update
apt install -y certbot python3-certbot-nginx

# Stop nginx temporarily for certificate generation
echo "Stopping nginx temporarily..."
systemctl stop nginx

# Generate SSL certificate
echo "Generating SSL certificate for bcpstudentlink.online..."
certbot certonly --standalone -d bcpstudentlink.online -d www.bcpstudentlink.online --non-interactive --agree-tos --email studentlink.bestlink@gmail.com

# Create HTTPS nginx configuration
echo "Creating HTTPS nginx configuration..."
cat > /etc/nginx/sites-available/bcpstudentlink.online << 'EOF'
# HTTP to HTTPS redirect
server {
    listen 80;
    server_name bcpstudentlink.online www.bcpstudentlink.online;
    return 301 https://$server_name$request_uri;
}

# HTTPS configuration
server {
    listen 443 ssl http2;
    server_name bcpstudentlink.online www.bcpstudentlink.online;
    
    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/bcpstudentlink.online/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/bcpstudentlink.online/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    
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

# Test nginx configuration
echo "Testing nginx configuration..."
nginx -t

# Start nginx
echo "Starting nginx..."
systemctl start nginx

# Setup automatic certificate renewal
echo "Setting up automatic certificate renewal..."
(crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew --quiet") | crontab -

# Test HTTPS access
echo "Testing HTTPS access..."
sleep 5
curl -I https://bcpstudentlink.online 2>/dev/null | head -1 || echo "❌ HTTPS test failed"

echo "✅ SSL Certificate setup complete!"
echo "🔒 Your site is now available at: https://bcpstudentlink.online"
echo "🔄 HTTP requests will automatically redirect to HTTPS"
