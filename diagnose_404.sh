#!/bin/bash

# StudentLink 404 Error Diagnostic Script
# This script will help identify what's causing the 404 error

echo "🔍 StudentLink 404 Error Diagnostic"
echo "===================================="

# Check if we're on the VPS
if [ ! -d "/var/www/bcpstudentlink.online" ]; then
    echo "❌ This script must be run on the VPS server"
    echo "Please SSH into your VPS and run this script there"
    exit 1
fi

cd /var/www/bcpstudentlink.online

echo "📊 System Information:"
echo "---------------------"
echo "Server: $(hostname)"
echo "Date: $(date)"
echo "User: $(whoami)"
echo ""

echo "🔍 Git Status:"
echo "-------------"
git status
echo ""
git log --oneline -3
echo ""

echo "📁 File Structure Check:"
echo "-----------------------"
echo "Checking if routing files exist:"
ls -la studentlink_web/app/page.tsx 2>/dev/null && echo "✅ Root page exists" || echo "❌ Root page missing"
ls -la studentlink_web/app/login/page.tsx 2>/dev/null && echo "✅ Login page exists" || echo "❌ Login page missing"
ls -la studentlink_web/middleware.ts 2>/dev/null && echo "✅ Middleware exists" || echo "❌ Middleware missing"
echo ""

echo "🔧 Service Status:"
echo "-----------------"
echo "Backend service:"
sudo systemctl status studentlink_backend --no-pager -l | head -10
echo ""
echo "Frontend service:"
sudo systemctl status studentlink-web --no-pager -l | head -10
echo ""
echo "Nginx service:"
sudo systemctl status nginx --no-pager -l | head -10
echo ""

echo "🌐 Port Status:"
echo "--------------"
echo "Port 80 (HTTP):"
sudo netstat -tlnp | grep :80 || echo "❌ Port 80 not listening"
echo ""
echo "Port 443 (HTTPS):"
sudo netstat -tlnp | grep :443 || echo "❌ Port 443 not listening"
echo ""
echo "Port 3000 (Frontend):"
sudo netstat -tlnp | grep :3000 || echo "❌ Port 3000 not listening"
echo ""
echo "Port 8000 (Backend):"
sudo netstat -tlnp | grep :8000 || echo "❌ Port 8000 not listening"
echo ""

echo "🧪 Connection Tests:"
echo "-------------------"
echo "Testing localhost connections:"
echo "Backend API (localhost:8000):"
curl -f -s http://localhost:8000/api/health > /dev/null && echo "✅ Backend API responding" || echo "❌ Backend API not responding"
echo ""
echo "Frontend (localhost:3000):"
curl -f -s http://localhost:3000 > /dev/null && echo "✅ Frontend responding" || echo "❌ Frontend not responding"
echo ""

echo "🌍 Public Access Tests:"
echo "----------------------"
echo "HTTPS Root:"
curl -I https://bcpstudentlink.online 2>/dev/null | head -5 || echo "❌ HTTPS root not accessible"
echo ""
echo "HTTPS Login:"
curl -I https://bcpstudentlink.online/login 2>/dev/null | head -5 || echo "❌ HTTPS login not accessible"
echo ""

echo "📝 Recent Logs:"
echo "--------------"
echo "Frontend logs (last 10 lines):"
sudo journalctl -u studentlink-web --no-pager -l -n 10
echo ""
echo "Backend logs (last 10 lines):"
sudo journalctl -u studentlink_backend --no-pager -l -n 10
echo ""
echo "Nginx error logs (last 10 lines):"
sudo tail -10 /var/log/nginx/error.log 2>/dev/null || echo "No Nginx error logs found"
echo ""

echo "🔧 Nginx Configuration:"
echo "----------------------"
echo "Checking Nginx config syntax:"
sudo nginx -t 2>&1 || echo "❌ Nginx configuration has errors"
echo ""

echo "📋 Next.js Build Status:"
echo "-----------------------"
if [ -d "studentlink_web/.next" ]; then
    echo "✅ Next.js build directory exists"
    ls -la studentlink_web/.next/ | head -5
else
    echo "❌ Next.js build directory missing"
fi
echo ""

echo "🔍 Environment Files:"
echo "--------------------"
echo "Frontend .env.local:"
if [ -f "studentlink_web/.env.local" ]; then
    echo "✅ .env.local exists"
    cat studentlink_web/.env.local | head -5
else
    echo "❌ .env.local missing"
fi
echo ""

echo "Backend .env:"
if [ -f "studentlink_backend/.env" ]; then
    echo "✅ Backend .env exists"
    echo "APP_URL: $(grep APP_URL studentlink_backend/.env)"
else
    echo "❌ Backend .env missing"
fi
echo ""

echo "🎯 Recommendations:"
echo "------------------"
echo "Based on the diagnostic results above:"
echo "1. If services are not running, restart them"
echo "2. If files are missing, pull the latest changes"
echo "3. If ports are not listening, check service configuration"
echo "4. If Nginx has errors, fix the configuration"
echo "5. If Next.js build is missing, run 'npm run build'"
echo ""
echo "Run the fix script: ./fix_404_error.sh"
