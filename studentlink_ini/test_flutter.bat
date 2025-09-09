@echo off
title Flutter Test
color 0D

echo.
echo ========================================
echo    Flutter Test Script
echo ========================================
echo.

:: Set the base directory
set "BASE_DIR=%~dp0"
cd /d "%BASE_DIR%"

echo [INFO] Testing Flutter setup...
echo.

:: Check Flutter version
echo [INFO] Flutter version:
flutter --version
echo.

:: Check available devices
echo [INFO] Available devices:
flutter devices
echo.

:: Test mobile directory
echo [INFO] Testing mobile directory...
cd /d "%BASE_DIR%studentlink_mobile"
if exist "pubspec.yaml" (
    echo [SUCCESS] pubspec.yaml found!
    echo [INFO] Getting Flutter dependencies...
    flutter pub get
    if %errorlevel% equ 0 (
        echo [SUCCESS] Dependencies installed!
        echo.
        echo [INFO] Ready to run Flutter app!
        echo [INFO] Run this command manually to test:
        echo    flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
    ) else (
        echo [ERROR] Failed to get dependencies!
    )
) else (
    echo [ERROR] pubspec.yaml not found in studentlink_mobile directory!
)

echo.
echo Press any key to exit...
pause >nul
