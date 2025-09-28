#!/bin/bash

# Quick Deploy Script - Copy files and start services

echo "🚀 Quick Deploy - Copying files and starting services..."

# Copy systemd service files
cp studentlink-backend.service /etc/systemd/system/
cp studentlink-frontend.service /etc/systemd/system/
cp studentlink-monitor.service /etc/systemd/system/

# Copy monitoring script
cp monitor_services.sh /var/www/
chmod +x /var/www/monitor_services.sh

# Reload systemd and start services
systemctl daemon-reload
systemctl enable studentlink-backend
systemctl enable studentlink-frontend
systemctl enable studentlink-monitor

systemctl start studentlink-backend
systemctl start studentlink-frontend
systemctl start studentlink-monitor

echo "✅ Services started! Check status with:"
echo "systemctl status studentlink-backend"
echo "systemctl status studentlink-frontend"
echo ""
echo "🌐 Your site should be live at: http://bcpstudentlink.online"
