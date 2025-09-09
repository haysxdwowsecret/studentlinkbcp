# 🚀 Quick Deployment Instructions

## Your VPS Credentials
- **VPS Password**: `Hellnoway@2025`
- **MySQL Password**: `hellnoway@2025`
- **Domain**: `bcpstudentlink.online`
- **IP**: `72.60.107.248`

## One-Click Deployment

### Step 1: Connect to Your VPS
```bash
ssh root@srv988639.hstgr.cloud
# Password: Hellnoway@2025
```

### Step 2: Clone and Deploy
```bash
# Clone your repository
git clone https://github.com/haysxdwowsecret/studentlinkbcp.git
cd studentlinkbcp

# Make scripts executable
chmod +x deploy_*.sh

# Run complete deployment
sudo ./deploy_all.sh
```

## What Happens During Deployment

1. **Server Setup** (5-10 minutes)
   - Installs LEMP stack (Nginx, MySQL, PHP 8.3)
   - Installs Node.js 18.x, Composer, Redis
   - Configures firewall and security
   - Creates MySQL database with your password

2. **Backend Deployment** (3-5 minutes)
   - Deploys Laravel API
   - Configures database connection
   - Runs migrations and seeds
   - Sets up production optimization

3. **Frontend Deployment** (2-3 minutes)
   - Builds Next.js for production
   - Creates systemd service
   - Configures environment variables

4. **SSL Configuration** (2-3 minutes)
   - Obtains Let's Encrypt certificate
   - Configures HTTPS redirect
   - Sets up automatic renewal

## After Deployment

Your system will be live at:
- **Web Portal**: https://bcpstudentlink.online
- **API**: https://bcpstudentlink.online/api
- **Health Check**: https://bcpstudentlink.online/api/health

## Next Steps

1. **Update API Keys** (Optional but recommended):
   ```bash
   nano /var/www/bcpstudentlink.online/studentlink_backend/.env
   # Add your OpenAI API key, Firebase credentials, etc.
   ```

2. **Update Mobile App**:
   - Change API URL to: `https://bcpstudentlink.online/api`
   - Build and deploy mobile app

3. **Test the System**:
   - Visit https://bcpstudentlink.online
   - Test API endpoints
   - Try demo accounts

## Troubleshooting

If deployment fails:
```bash
# Check logs
journalctl -u studentlink-web -f

# Run health check
/usr/local/bin/studentlink-health-check.sh

# Restart services
systemctl restart nginx
systemctl restart studentlink-web
```

## Demo Accounts

Use these accounts to test the system:
- **Admin**: admin@bestlink.edu.ph / admin123
- **Staff**: staff@bestlink.edu.ph / staff123
- **Faculty**: faculty@bestlink.edu.ph / faculty123
- **Student**: student@bestlink.edu.ph / student123

---

**Total deployment time: 10-20 minutes**

**Your StudentLink system will be running 24/7 on your Hostinger VPS!**
