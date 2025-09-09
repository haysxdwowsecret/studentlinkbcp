@echo off
echo ========================================
echo    StudentLink Deploy and Start Script
echo ========================================
echo.

echo [1/8] Connecting to VPS...
ssh root@72.60.107.248 "echo 'Connected to VPS successfully'"

echo.
echo [2/8] Pulling Latest Changes...
ssh root@72.60.107.248 "cd /var/www/bcpstudentlink.online && git pull origin master"

echo.
echo [3/8] Clearing Laravel Cache...
ssh root@72.60.107.248 "cd /var/www/bcpstudentlink.online/studentlink_backend && php artisan config:clear && php artisan cache:clear && php artisan route:clear"

echo.
echo [4/8] Building Web Portal...
ssh root@72.60.107.248 "cd /var/www/bcpstudentlink.online/studentlink_web && npm run build"

echo.
echo [5/8] Starting Backend Service...
ssh root@72.60.107.248 "systemctl start studentlink_backend.service && systemctl status studentlink_backend.service --no-pager -l"

echo.
echo [6/8] Starting Web Portal Service...
ssh root@72.60.107.248 "systemctl start studentlink-web.service && systemctl status studentlink-web.service --no-pager -l"

echo.
echo [7/8] Starting Queue Service...
ssh root@72.60.107.248 "systemctl start studentlink-queue.service && systemctl status studentlink-queue.service --no-pager -l"

echo.
echo [8/8] Starting Nginx (SSL)...
ssh root@72.60.107.248 "systemctl start nginx && systemctl status nginx --no-pager -l"

echo.
echo ========================================
echo    Deploy and Start Complete!
echo ========================================
echo.
echo Testing Services...
echo.
echo Backend API Health:
ssh root@72.60.107.248 "curl -I http://localhost:8000/api/health"

echo.
echo Web Portal:
ssh root@72.60.107.248 "curl -I https://bcpstudentlink.online"

echo.
echo ========================================
echo    System is Ready!
echo ========================================
echo.
echo Backend API: http://localhost:8000
echo Web Portal: https://bcpstudentlink.online
echo.
echo Press any key to exit...
pause > nul
