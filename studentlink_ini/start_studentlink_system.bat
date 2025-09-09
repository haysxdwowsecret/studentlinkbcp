@echo off
title StudentLink System Launcher
color 0A

echo.
echo ========================================
echo    StudentLink System Launcher
echo    Bestlink College of the Philippines
echo ========================================
echo.

:: Set the base directory (where this batch file is located)
set "BASE_DIR=%~dp0"
cd /d "%BASE_DIR%"

:: Check if required directories exist
echo [INFO] Checking system components...
if not exist "studentlink_backend" (
    echo [ERROR] Backend directory not found!
    pause
    exit /b 1
)
if not exist "studentlink_web" (
    echo [ERROR] Web directory not found!
    pause
    exit /b 1
)
if not exist "studentlink_mobile" (
    echo [ERROR] Mobile directory not found!
    pause
    exit /b 1
)
echo [SUCCESS] All components found!
echo.

:: Check for required tools
echo [INFO] Checking required tools...

:: Check for PHP
php --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] PHP is not installed or not in PATH!
    echo Please install PHP 8.1+ and add it to your PATH.
    pause
    exit /b 1
)
echo [SUCCESS] PHP found!

:: Check for Composer
composer --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Composer is not installed or not in PATH!
    echo Please install Composer and add it to your PATH.
    pause
    exit /b 1
)
echo [SUCCESS] Composer found!

:: Check for Node.js
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Node.js is not installed or not in PATH!
    echo Please install Node.js 18+ and add it to your PATH.
    pause
    exit /b 1
)
echo [SUCCESS] Node.js found!

:: Check for npm
npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] npm is not installed or not in PATH!
    pause
    exit /b 1
)
echo [SUCCESS] npm found!

:: Check for Flutter
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] Flutter is not installed or not in PATH!
    echo Mobile app will be skipped. Install Flutter 3.6.0+ to enable mobile development.
    set "SKIP_MOBILE=1"
) else (
    echo [SUCCESS] Flutter found!
    set "SKIP_MOBILE=0"
)

echo.
echo [INFO] All required tools are available!
echo.

:: Function to start backend
:start_backend
echo ========================================
echo    Starting Laravel Backend Server
echo ========================================
echo.

cd /d "%BASE_DIR%studentlink_backend"

:: Check if .env exists, if not copy from .env.example
if not exist ".env" (
    if exist ".env.example" (
        echo [INFO] Creating .env file from .env.example...
        copy ".env.example" ".env" >nul
        echo [INFO] Please configure your .env file with proper database settings!
    ) else (
        echo [WARNING] No .env.example found. Please create .env file manually.
    )
)

:: Install dependencies if vendor directory doesn't exist
if not exist "vendor" (
    echo [INFO] Installing PHP dependencies...
    composer install --no-interaction
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to install PHP dependencies!
        pause
        exit /b 1
    )
)

:: Generate application key if not set
echo [INFO] Checking application key...
php artisan key:generate --force >nul 2>&1

:: Run migrations (optional - uncomment if needed)
:: echo [INFO] Running database migrations...
:: php artisan migrate --force

:: Start Laravel development server
echo [INFO] Starting Laravel backend server on http://localhost:8000...
echo [INFO] Backend API will be available at: http://localhost:8000/api
echo.
start "StudentLink Backend" cmd /k "php artisan serve --host=0.0.0.0 --port=8000"

:: Wait a moment for backend to start
timeout /t 3 /nobreak >nul

:: Function to start web frontend
:start_web
echo ========================================
echo    Starting Next.js Web Portal
echo ========================================
echo.

cd /d "%BASE_DIR%studentlink_web"

:: Install dependencies if node_modules doesn't exist
if not exist "node_modules" (
    echo [INFO] Installing Node.js dependencies...
    npm install
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to install Node.js dependencies!
        pause
        exit /b 1
    )
)

:: Check for .env.local file
if not exist ".env.local" (
    echo [WARNING] .env.local file not found!
    echo [INFO] Creating basic .env.local file...
    (
        echo NEXT_PUBLIC_API_BASE_URL=http://localhost:8000/api
        echo NEXT_PUBLIC_WEB_BASE_URL=http://localhost:3000
        echo NEXT_PUBLIC_APP_NAME=StudentLink Web Portal
        echo NEXT_PUBLIC_COLLEGE_NAME=Bestlink College of the Philippines
        echo NEXT_PUBLIC_ENABLE_AI_FEATURES=true
        echo NEXT_PUBLIC_ENABLE_PUSH_NOTIFICATIONS=true
        echo NEXT_PUBLIC_DEBUG_MODE=true
    ) > .env.local
    echo [INFO] Please configure your .env.local file with proper settings!
)

:: Start Next.js development server
echo [INFO] Starting Next.js web portal on http://localhost:3000...
echo [INFO] Web portal will be available at: http://localhost:3000
echo.
start "StudentLink Web Portal" cmd /k "npm run dev"

:: Wait a moment for web to start
timeout /t 3 /nobreak >nul

:: Function to start mobile app (if Flutter is available)
:start_mobile
if "%SKIP_MOBILE%"=="1" (
    echo ========================================
    echo    Mobile App - SKIPPED
    echo ========================================
    echo [INFO] Flutter not available. Mobile app startup skipped.
    echo [INFO] Install Flutter 3.6.0+ to enable mobile development.
    goto :show_summary
)

echo ========================================
echo    Starting Flutter Mobile App
echo ========================================
echo.

cd /d "%BASE_DIR%studentlink_mobile"

:: Get Flutter dependencies
echo [INFO] Getting Flutter dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo [ERROR] Failed to get Flutter dependencies!
    echo [INFO] Continuing without mobile app...
    goto :show_summary
)

:: Check for available devices
echo [INFO] Checking for available devices...
flutter devices >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] No Flutter devices found!
    echo [INFO] Make sure you have an emulator running or device connected.
    echo [INFO] You can start the mobile app manually later with: flutter run
    goto :show_summary
)

:: Start Flutter app
echo [INFO] Starting Flutter mobile app...
echo [INFO] Mobile app will launch on the first available device.
echo.
start "StudentLink Mobile" cmd /k "flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api --dart-define=DEBUG_MODE=true"

:: Show summary
:show_summary
echo.
echo ========================================
echo    StudentLink System Started!
echo ========================================
echo.
echo [SUCCESS] All components have been started:
echo.
echo    Backend API:     http://localhost:8000
echo    Web Portal:      http://localhost:3000
if "%SKIP_MOBILE%"=="0" (
    echo    Mobile App:      Running on device/emulator
) else (
    echo    Mobile App:      Skipped (Flutter not available)
)
echo.
echo [INFO] Demo Accounts for Testing:
echo.
echo    Administrator:   admin@bestlink.edu.ph / admin123
echo    Department Head: depthead@bestlink.edu.ph / dept123
echo    Staff:           staff@bestlink.edu.ph / staff123
echo    Faculty:         faculty@bestlink.edu.ph / faculty123
echo    Student:         student@bestlink.edu.ph / student123
echo.
echo [INFO] Each component is running in its own command window.
echo [INFO] Close individual windows to stop specific components.
echo [INFO] Press any key to close this launcher window...
echo.
pause >nul

:: Optional: Open browsers automatically
echo [INFO] Opening web browsers...
start http://localhost:3000
start http://localhost:8000/api/test

echo.
echo [INFO] StudentLink system is now running!
echo [INFO] Happy coding! 🚀
echo.
