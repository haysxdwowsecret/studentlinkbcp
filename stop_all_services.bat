@echo off
echo ========================================
echo    StudentLink System Shutdown Script
echo ========================================
echo.

echo [1/5] Connecting to VPS...
ssh root@72.60.107.248 "echo 'Connected to VPS successfully'"

echo.
echo [2/5] Stopping Backend Service...
ssh root@72.60.107.248 "systemctl stop studentlink_backend.service && echo 'Backend service stopped'"

echo.
echo [3/5] Stopping Web Portal Service...
ssh root@72.60.107.248 "systemctl stop studentlink-web.service && echo 'Web portal service stopped'"

echo.
echo [4/5] Stopping Queue Service...
ssh root@72.60.107.248 "systemctl stop studentlink-queue.service && echo 'Queue service stopped'"

echo.
echo [5/5] Stopping Nginx (SSL)...
ssh root@72.60.107.248 "systemctl stop nginx && echo 'Nginx service stopped'"

echo.
echo ========================================
echo    All Services Stopped Successfully!
echo ========================================
echo.
echo Press any key to exit...
pause > nul
