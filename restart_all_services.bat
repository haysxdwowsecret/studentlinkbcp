@echo off
echo ========================================
echo    StudentLink System Restart Script
echo ========================================
echo.

echo [1/7] Connecting to VPS...
ssh root@72.60.107.248 "echo 'Connected to VPS successfully'"

echo.
echo [2/7] Stopping All Services...
ssh root@72.60.107.248 "systemctl stop studentlink_backend.service studentlink-web.service studentlink-queue.service nginx && echo 'All services stopped'"

echo.
echo [3/7] Starting Backend Service...
ssh root@72.60.107.248 "systemctl start studentlink_backend.service && systemctl status studentlink_backend.service --no-pager -l"

echo.
echo [4/7] Starting Web Portal Service...
ssh root@72.60.107.248 "systemctl start studentlink-web.service && systemctl status studentlink-web.service --no-pager -l"

echo.
echo [5/7] Starting Queue Service...
ssh root@72.60.107.248 "systemctl start studentlink-queue.service && systemctl status studentlink-queue.service --no-pager -l"

echo.
echo [6/7] Starting Nginx (SSL)...
ssh root@72.60.107.248 "systemctl start nginx && systemctl status nginx --no-pager -l"

echo.
echo [7/7] Testing All Services...
echo Testing Backend API...
ssh root@72.60.107.248 "curl -I http://localhost:8000/api/health"

echo.
echo Testing Web Portal...
ssh root@72.60.107.248 "curl -I https://bcpstudentlink.online"

echo.
echo ========================================
echo    All Services Restarted Successfully!
echo ========================================
echo.
echo Backend API: http://localhost:8000
echo Web Portal: https://bcpstudentlink.online
echo.
echo Press any key to exit...
pause > nul
