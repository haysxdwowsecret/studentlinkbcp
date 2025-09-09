@echo off
echo ========================================
echo    StudentLink System Startup Script
echo ========================================
echo.

echo [1/6] Connecting to VPS...
ssh root@72.60.107.248 "echo 'Connected to VPS successfully'"

echo.
echo [2/6] Starting Backend Service...
ssh root@72.60.107.248 "systemctl start studentlink_backend.service && systemctl status studentlink_backend.service --no-pager -l"

echo.
echo [3/6] Starting Web Portal Service...
ssh root@72.60.107.248 "systemctl start studentlink-web.service && systemctl status studentlink-web.service --no-pager -l"

echo.
echo [4/6] Starting Queue Service...
ssh root@72.60.107.248 "systemctl start studentlink-queue.service && systemctl status studentlink-queue.service --no-pager -l"

echo.
echo [5/6] Starting Nginx (SSL)...
ssh root@72.60.107.248 "systemctl start nginx && systemctl status nginx --no-pager -l"

echo.
echo [6/6] Testing All Services...
echo Testing Backend API...
ssh root@72.60.107.248 "curl -I http://localhost:8000/api/health"

echo.
echo Testing Web Portal...
ssh root@72.60.107.248 "curl -I https://bcpstudentlink.online"

echo.
echo ========================================
echo    All Services Started Successfully!
echo ========================================
echo.
echo Backend API: http://localhost:8000
echo Web Portal: https://bcpstudentlink.online
echo.
echo Press any key to exit...
pause > nul
