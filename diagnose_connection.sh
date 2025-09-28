#!/bin/bash

# Comprehensive Connection Diagnostic Script
echo "🔍 Diagnosing Connection Issues..."

echo ""
echo "=== 1. CHECKING SERVICES ==="
systemctl status nginx --no-pager -l | head -5
systemctl status studentlink-backend --no-pager -l | head -5
systemctl status studentlink-frontend --no-pager -l | head -5

echo ""
echo "=== 2. CHECKING PORTS ==="
netstat -tlnp | grep -E "(80|3000|8000)"

echo ""
echo "=== 3. CHECKING NGINX CONFIG ==="
nginx -t
echo "Enabled sites:"
ls -la /etc/nginx/sites-enabled/

echo ""
echo "=== 4. TESTING LOCAL CONNECTIONS ==="
echo "Testing localhost:80..."
curl -I http://localhost 2>/dev/null | head -1 || echo "❌ localhost:80 failed"
echo "Testing localhost:3000..."
curl -I http://localhost:3000 2>/dev/null | head -1 || echo "❌ localhost:3000 failed"
echo "Testing localhost:8000..."
curl -I http://localhost:8000 2>/dev/null | head -1 || echo "❌ localhost:8000 failed"

echo ""
echo "=== 5. CHECKING FIREWALL ==="
ufw status

echo ""
echo "=== 6. CHECKING DNS RESOLUTION ==="
echo "Resolving bcpstudentlink.online..."
nslookup bcpstudentlink.online

echo ""
echo "=== 7. TESTING EXTERNAL ACCESS ==="
echo "Testing from server to itself..."
curl -I http://bcpstudentlink.online 2>/dev/null | head -1 || echo "❌ External access failed"

echo ""
echo "=== 8. CHECKING NGINX ACCESS LOGS ==="
echo "Recent access attempts:"
tail -10 /var/log/nginx/access.log 2>/dev/null || echo "No access log found"

echo ""
echo "=== 9. CHECKING NGINX ERROR LOGS ==="
echo "Recent errors:"
tail -10 /var/log/nginx/error.log 2>/dev/null || echo "No error log found"

echo ""
echo "=== 10. NETWORK INTERFACE INFO ==="
ip addr show | grep -E "(inet|UP)"

echo ""
echo "🔍 Diagnostic complete!"
