@echo off
echo ========================================
echo    StudentLink System Status Check
echo ========================================
echo.

echo [1/4] Connecting to VPS...
ssh root@72.60.107.248 "echo 'Connected to VPS successfully'"

echo.
echo [2/4] Checking Service Status...
echo.
echo === Backend Service ===
ssh root@72.60.107.248 "systemctl status studentlink_backend.service --no-pager -l"

echo.
echo === Web Portal Service ===
ssh root@72.60.107.248 "systemctl status studentlink-web.service --no-pager -l"

echo.
echo === Queue Service ===
ssh root@72.60.107.248 "systemctl status studentlink-queue.service --no-pager -l"

echo.
echo === Nginx Service ===
ssh root@72.60.107.248 "systemctl status nginx --no-pager -l"

echo.
echo [3/4] Testing API Endpoints...
echo.
echo Testing Backend Health...
ssh root@72.60.107.248 "curl -I http://localhost:8000/api/health"

echo.
echo Testing Web Portal...
ssh root@72.60.107.248 "curl -I https://bcpstudentlink.online"

echo.
echo [4/4] Testing Login API...
ssh root@72.60.107.248 "curl -X POST https://bcpstudentlink.online/api/auth/login -H 'Content-Type: application/json' -d '{\"email\":\"admin@bestlink.edu.ph\",\"password\":\"admin123\"}' -s"

echo.
echo ========================================
echo    System Status Check Complete!
echo ========================================
echo.
echo Press any key to exit...
pause > nul
