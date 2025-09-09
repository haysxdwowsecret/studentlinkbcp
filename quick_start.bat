@echo off
title StudentLink Quick Start
color 0B

echo.
echo ========================================
echo    StudentLink Quick Start
echo ========================================
echo.

:: Set the base directory
set "BASE_DIR=%~dp0"
cd /d "%BASE_DIR%"

:: Start Backend
echo [INFO] Starting Backend...
cd /d "%BASE_DIR%studentlink_backend"
start "Backend" cmd /k "php artisan serve --host=0.0.0.0 --port=8000"

:: Wait 2 seconds
timeout /t 2 /nobreak >nul

:: Start Web
echo [INFO] Starting Web Portal...
cd /d "%BASE_DIR%studentlink_web"
start "Web Portal" cmd /k "npm run dev"

:: Wait 2 seconds
timeout /t 2 /nobreak >nul

:: Start Mobile (if Flutter available)
echo [INFO] Starting Mobile App...
cd /d "%BASE_DIR%studentlink_mobile"
flutter --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [INFO] Flutter found! Starting mobile app...
    echo [INFO] Available devices:
    flutter devices --machine >nul 2>&1
    if %errorlevel% equ 0 (
        echo [INFO] Starting Flutter app on first available device...
        start "Mobile App" cmd /k "cd /d \"%BASE_DIR%studentlink_mobile\" && echo Installing dependencies... && flutter pub get && echo Starting app... && flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api --dart-define=DEBUG_MODE=true"
    ) else (
        echo [WARNING] No Flutter devices found!
        echo [INFO] Please connect a device or start an emulator first.
        echo [INFO] Run 'flutter devices' to see available devices.
    )
) else (
    echo [WARNING] Flutter not found - Mobile app skipped
    echo [INFO] Install Flutter 3.6.0+ to enable mobile development
)

:: Open browsers
echo [INFO] Opening web browsers...
timeout /t 3 /nobreak >nul
start http://localhost:3000
start http://localhost:8000/api/test

echo.
echo [SUCCESS] StudentLink system started!
echo    Backend:  http://localhost:8000
echo    Web:      http://localhost:3000
echo.
echo Press any key to close...
pause >nul
