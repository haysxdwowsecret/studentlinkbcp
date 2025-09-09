@echo off
title StudentLink System Setup
color 0E

echo.
echo ========================================
echo    StudentLink System Setup
echo    First-Time Installation
echo ========================================
echo.

:: Set the base directory
set "BASE_DIR=%~dp0"
cd /d "%BASE_DIR%"

echo [INFO] This script will set up the StudentLink system for first-time use.
echo [INFO] Make sure you have the following installed:
echo.
echo    - PHP 8.1+ with Composer
echo    - Node.js 18+ with npm
echo    - MySQL 8.0+ (running)
echo    - Flutter 3.6.0+ (optional for mobile)
echo.
echo Press any key to continue or Ctrl+C to cancel...
pause >nul

echo.
echo [INFO] Starting setup process...
echo.

:: Setup Backend
echo ========================================
echo    Setting up Laravel Backend
echo ========================================
echo.

cd /d "%BASE_DIR%studentlink_backend"

:: Install PHP dependencies
echo [INFO] Installing PHP dependencies...
composer install --no-interaction
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install PHP dependencies!
    echo [INFO] Please check your Composer installation.
    pause
    exit /b 1
)

:: Setup environment file
if not exist ".env" (
    if exist ".env.example" (
        echo [INFO] Creating .env file from .env.example...
        copy ".env.example" ".env" >nul
        echo [SUCCESS] .env file created!
    ) else (
        echo [WARNING] No .env.example found. Creating basic .env file...
        (
            echo APP_NAME=StudentLink
            echo APP_ENV=local
            echo APP_KEY=
            echo APP_DEBUG=true
            echo APP_URL=http://localhost:8000
            echo.
            echo DB_CONNECTION=mysql
            echo DB_HOST=127.0.0.1
            echo DB_PORT=3306
            echo DB_DATABASE=studentlink
            echo DB_USERNAME=root
            echo DB_PASSWORD=
            echo.
            echo JWT_SECRET=your_jwt_secret_here
            echo OPENAI_API_KEY=
            echo FIREBASE_PROJECT_ID=
        ) > .env
        echo [SUCCESS] Basic .env file created!
    )
) else (
    echo [INFO] .env file already exists.
)

:: Generate application key
echo [INFO] Generating application key...
php artisan key:generate --force >nul 2>&1

:: Run migrations
echo [INFO] Running database migrations...
echo [WARNING] Make sure MySQL is running and database 'studentlink' exists!
php artisan migrate --force
if %errorlevel% neq 0 (
    echo [ERROR] Database migration failed!
    echo [INFO] Please check your MySQL connection and database settings.
    echo [INFO] You can run migrations manually later with: php artisan migrate
)

:: Seed database
echo [INFO] Seeding database with demo data...
php artisan db:seed --force
if %errorlevel% neq 0 (
    echo [WARNING] Database seeding failed!
    echo [INFO] You can run seeding manually later with: php artisan db:seed
)

echo [SUCCESS] Backend setup completed!
echo.

:: Setup Web Portal
echo ========================================
echo    Setting up Next.js Web Portal
echo ========================================
echo.

cd /d "%BASE_DIR%studentlink_web"

:: Install Node.js dependencies
echo [INFO] Installing Node.js dependencies...
npm install
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install Node.js dependencies!
    echo [INFO] Please check your Node.js and npm installation.
    pause
    exit /b 1
)

:: Setup environment file
if not exist ".env.local" (
    echo [INFO] Creating .env.local file...
    (
        echo NEXT_PUBLIC_API_BASE_URL=http://localhost:8000/api
        echo NEXT_PUBLIC_WEB_BASE_URL=http://localhost:3000
        echo NEXT_PUBLIC_APP_NAME=StudentLink Web Portal
        echo NEXT_PUBLIC_COLLEGE_NAME=Bestlink College of the Philippines
        echo NEXT_PUBLIC_ENABLE_AI_FEATURES=true
        echo NEXT_PUBLIC_ENABLE_PUSH_NOTIFICATIONS=true
        echo NEXT_PUBLIC_DEBUG_MODE=true
    ) > .env.local
    echo [SUCCESS] .env.local file created!
) else (
    echo [INFO] .env.local file already exists.
)

echo [SUCCESS] Web portal setup completed!
echo.

:: Setup Mobile App
echo ========================================
echo    Setting up Flutter Mobile App
echo ========================================
echo.

cd /d "%BASE_DIR%studentlink_mobile"

:: Check if Flutter is available
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] Flutter is not installed or not in PATH!
    echo [INFO] Mobile app setup skipped.
    echo [INFO] Install Flutter 3.6.0+ to enable mobile development.
    set "MOBILE_SETUP=0"
) else (
    echo [INFO] Getting Flutter dependencies...
    flutter pub get
    if %errorlevel% neq 0 (
        echo [WARNING] Failed to get Flutter dependencies!
        echo [INFO] Mobile app setup incomplete.
        set "MOBILE_SETUP=0"
    ) else (
        echo [SUCCESS] Flutter dependencies installed!
        set "MOBILE_SETUP=1"
    )
)

echo.
echo ========================================
echo    Setup Complete!
echo ========================================
echo.

echo [SUCCESS] StudentLink system setup completed!
echo.
echo [INFO] What was set up:
echo    ✓ Laravel Backend (PHP dependencies, .env, migrations)
echo    ✓ Next.js Web Portal (Node.js dependencies, .env.local)
if "%MOBILE_SETUP%"=="1" (
    echo    ✓ Flutter Mobile App (dependencies)
) else (
    echo    ⚠ Flutter Mobile App (skipped - Flutter not available)
)
echo.
echo [INFO] Next steps:
echo    1. Configure your .env file in studentlink_backend/ with database settings
echo    2. Make sure MySQL is running and create database 'studentlink'
echo    3. Run 'start_studentlink_system.bat' to start the system
echo.
echo [INFO] Demo accounts will be available after running migrations:
echo    Admin: admin@bestlink.edu.ph / admin123
echo    Student: student@bestlink.edu.ph / student123
echo.
echo Press any key to exit...
pause >nul
