# StudentLink System Launcher

This directory contains batch files to easily start and stop the entire StudentLink system with a single click.

## 🚀 Quick Start

### For First-Time Setup
1. **Run Setup First**: Double-click `setup_studentlink.bat` - This will:
   - Install all dependencies
   - Set up environment files
   - Run database migrations
   - Create demo data

2. **Start the System**: Double-click `start_studentlink_system.bat` - This will:
   - Check for all required tools (PHP, Composer, Node.js, Flutter)
   - Start all components
   - Open web browsers automatically

### For Daily Development
Double-click `quick_start.bat` - This will:
- Quickly start all components without checks
- Open web browsers
- Perfect for when everything is already set up

### To Stop Everything
Double-click `stop_studentlink_system.bat` - This will:
- Stop all running components
- Kill processes on ports 8000 and 3000
- Clean up any hanging processes

## 📋 Prerequisites

Before using these launchers, make sure you have:

### Required Software
- **PHP 8.1+** - For Laravel backend
- **Composer** - PHP dependency manager
- **Node.js 18+** - For Next.js web portal
- **npm** - Node.js package manager
- **Flutter 3.6.0+** - For mobile app (optional)

### Database
- **MySQL 8.0+** - Database server [[memory:8375967]]
- Make sure MySQL is running before starting the system

## 🎯 What Gets Started

### 1. Laravel Backend (Port 8000)
- **URL**: http://localhost:8000
- **API**: http://localhost:8000/api
- **Health Check**: http://localhost:8000/api/health

### 2. Next.js Web Portal (Port 3000)
- **URL**: http://localhost:3000
- **Admin Panel**: http://localhost:3000/admin
- **Faculty Portal**: http://localhost:3000/faculty

### 3. Flutter Mobile App
- Runs on connected device or emulator
- Connects to backend via http://10.0.2.2:8000/api

## 🔐 Demo Accounts

Use these accounts to test the system:

| Role | Email | Password | Access Level |
|------|-------|----------|--------------|
| **Administrator** | admin@bestlink.edu.ph | admin123 | Full system access |
| **Department Head** | depthead@bestlink.edu.ph | dept123 | Department management |
| **Staff** | staff@bestlink.edu.ph | staff123 | Assigned concerns |
| **Faculty** | faculty@bestlink.edu.ph | faculty123 | Student concerns |
| **Student** | student@bestlink.edu.ph | student123 | Submit concerns |

## 🛠️ Manual Setup (If Batch Files Don't Work)

### Backend Setup
```bash
cd studentlink_backend
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate
php artisan serve
```

### Web Portal Setup
```bash
cd studentlink_web
npm install
cp env.example .env.local
npm run dev
```

### Mobile App Setup
```bash
cd studentlink_mobile
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```

## 🔧 Troubleshooting

### Common Issues

#### "PHP is not installed"
- Install PHP 8.1+ from https://php.net
- Add PHP to your system PATH
- Restart command prompt

#### "Composer is not installed"
- Install Composer from https://getcomposer.org
- Add Composer to your system PATH
- Restart command prompt

#### "Node.js is not installed"
- Install Node.js 18+ from https://nodejs.org
- npm comes with Node.js
- Restart command prompt

#### "Flutter is not installed"
- Install Flutter 3.6.0+ from https://flutter.dev
- Add Flutter to your system PATH
- Run `flutter doctor` to check setup

#### "Database connection failed"
- Make sure MySQL is running
- Check database credentials in `.env` file
- Run `php artisan migrate` to set up database

#### "Port already in use"
- Stop other applications using ports 8000 or 3000
- Use `stop_studentlink_system.bat` to clean up
- Or change ports in configuration files

### Getting Help

1. **Check the logs** in each command window
2. **Verify prerequisites** are installed correctly
3. **Check database connection** and credentials
4. **Review environment files** for correct settings
5. **Contact support** if issues persist

## 📁 File Structure

```
studentlink_web/
├── setup_studentlink.bat           # First-time setup
├── start_studentlink_system.bat    # Full setup and start
├── quick_start.bat                 # Quick start (no checks)
├── stop_studentlink_system.bat     # Stop all components
├── SYSTEM_LAUNCHER_README.md       # This file
├── studentlink_backend/            # Laravel backend
├── studentlink_web/                # Next.js web portal
└── studentlink_mobile/             # Flutter mobile app
```

## 🎉 Success!

When everything is running, you should see:
- Backend API responding at http://localhost:8000/api/test
- Web portal accessible at http://localhost:3000
- Mobile app running on your device/emulator
- All components communicating properly

Happy coding! 🚀

---

**Built for Bestlink College of the Philippines**  
*StudentLink System - Connecting Students, Faculty, and Staff*
