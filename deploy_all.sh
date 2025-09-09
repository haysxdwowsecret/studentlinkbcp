#!/bin/bash

# StudentLink Complete Deployment Script
# This script runs all deployment steps in sequence

set -e  # Exit on any error

echo "🚀 StudentLink Complete Deployment Script"
echo "========================================="
echo "This script will deploy your entire StudentLink system to your Hostinger VPS"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Please run this script as root"
    echo "Usage: sudo ./deploy_all.sh"
    exit 1
fi

# Confirm deployment
echo "📋 Deployment Details:"
echo "• Server: srv988639.hstgr.cloud (72.60.107.248)"
echo "• Domain: bcpstudentlink.online"
echo "• OS: Ubuntu 24.04 LTS"
echo ""
read -p "Do you want to proceed with the deployment? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled."
    exit 1
fi

# Make all scripts executable
echo "🔧 Making deployment scripts executable..."
chmod +x deploy_server_setup.sh
chmod +x deploy_backend.sh
chmod +x deploy_frontend.sh
chmod +x deploy_ssl.sh

# Step 1: Server Setup
echo ""
echo "📦 STEP 1: Server Setup"
echo "======================="
./deploy_server_setup.sh

if [ $? -eq 0 ]; then
    echo "✅ Server setup completed successfully!"
else
    echo "❌ Server setup failed!"
    exit 1
fi

# Step 2: Backend Deployment
echo ""
echo "🔧 STEP 2: Backend Deployment"
echo "============================="
./deploy_backend.sh

if [ $? -eq 0 ]; then
    echo "✅ Backend deployment completed successfully!"
else
    echo "❌ Backend deployment failed!"
    exit 1
fi

# Step 3: Frontend Deployment
echo ""
echo "🌐 STEP 3: Frontend Deployment"
echo "=============================="
./deploy_frontend.sh

if [ $? -eq 0 ]; then
    echo "✅ Frontend deployment completed successfully!"
else
    echo "❌ Frontend deployment failed!"
    exit 1
fi

# Step 4: SSL Configuration
echo ""
echo "🔒 STEP 4: SSL Configuration"
echo "============================"
./deploy_ssl.sh

if [ $? -eq 0 ]; then
    echo "✅ SSL configuration completed successfully!"
else
    echo "❌ SSL configuration failed!"
    exit 1
fi

# Final system check
echo ""
echo "🏥 FINAL SYSTEM CHECK"
echo "====================="
/usr/local/bin/studentlink-health-check.sh

echo ""
echo "🎉 DEPLOYMENT COMPLETED SUCCESSFULLY!"
echo "====================================="
echo ""
echo "🌐 Your StudentLink system is now live at:"
echo "• Web Portal: https://bcpstudentlink.online"
echo "• API Endpoint: https://bcpstudentlink.online/api"
echo "• Health Check: https://bcpstudentlink.online/api/health"
echo ""
echo "📱 Mobile App Configuration:"
echo "Update your Flutter app to use: https://bcpstudentlink.online/api"
echo ""
echo "🔧 Next Steps:"
echo "1. Update API keys in backend .env file:"
echo "   /var/www/bcpstudentlink.online/studentlink_backend/.env"
echo ""
echo "2. Update Firebase credentials in frontend .env.local:"
echo "   /var/www/bcpstudentlink.online/studentlink_web/.env.local"
echo ""
echo "3. Test the complete system with demo accounts"
echo ""
echo "📊 System Management:"
echo "• Health Check: /usr/local/bin/studentlink-health-check.sh"
echo "• SSL Monitor: /usr/local/bin/ssl-monitor.sh"
echo "• View Logs: journalctl -u studentlink-web -f"
echo "• Restart Services: systemctl restart studentlink-web"
echo ""
echo "🔒 Security Features:"
echo "• SSL/TLS encryption with Let's Encrypt"
echo "• Automatic certificate renewal"
echo "• Firewall configured (UFW)"
echo "• Security headers enabled"
echo ""
echo "🎓 Congratulations! Your StudentLink system is ready for Bestlink College!"
