#!/bin/bash

# Fix Firewall and Network Access
echo "🔧 Fixing Firewall and Network Access..."

# Check current firewall status
echo "Current firewall status:"
ufw status

# Allow HTTP and HTTPS traffic
echo "Opening firewall ports..."
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 3000/tcp
ufw allow 8000/tcp

# Enable firewall if not already enabled
ufw --force enable

# Check if ports are properly opened
echo "Checking open ports:"
netstat -tlnp | grep -E "(80|443|3000|8000)"

# Restart nginx to ensure it's listening on all interfaces
systemctl restart nginx

# Test local access
echo "Testing local access..."
curl -I http://localhost 2>/dev/null | head -1 || echo "❌ Local access failed"

echo "✅ Firewall configuration updated!"
echo "🌐 Try accessing your site now: http://bcpstudentlink.online"
