@echo off
title StudentLink System Stopper
color 0C

echo.
echo ========================================
echo    StudentLink System Stopper
echo ========================================
echo.

echo [INFO] Stopping all StudentLink components...
echo.

:: Kill processes by window title
echo [INFO] Stopping Backend server...
taskkill /f /fi "WINDOWTITLE eq StudentLink Backend*" >nul 2>&1
taskkill /f /fi "WINDOWTITLE eq Backend*" >nul 2>&1

echo [INFO] Stopping Web Portal...
taskkill /f /fi "WINDOWTITLE eq StudentLink Web Portal*" >nul 2>&1
taskkill /f /fi "WINDOWTITLE eq Web Portal*" >nul 2>&1

echo [INFO] Stopping Mobile App...
taskkill /f /fi "WINDOWTITLE eq StudentLink Mobile*" >nul 2>&1
taskkill /f /fi "WINDOWTITLE eq Mobile App*" >nul 2>&1

:: Kill processes by port (more aggressive)
echo [INFO] Stopping processes on ports 8000 and 3000...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :8000') do (
    taskkill /f /pid %%a >nul 2>&1
)
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :3000') do (
    taskkill /f /pid %%a >nul 2>&1
)

:: Kill any remaining Node.js processes (be careful with this)
echo [INFO] Stopping Node.js processes...
taskkill /f /im node.exe >nul 2>&1

:: Kill any remaining PHP processes (be careful with this)
echo [INFO] Stopping PHP processes...
taskkill /f /im php.exe >nul 2>&1

echo.
echo [SUCCESS] All StudentLink components have been stopped!
echo.
echo [INFO] If you want to start the system again, run:
echo    - start_studentlink_system.bat (full setup with checks)
echo    - quick_start.bat (quick startup)
echo.
pause
