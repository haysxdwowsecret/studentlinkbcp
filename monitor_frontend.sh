#!/bin/bash

# Monitor Frontend Service
echo "🔍 Monitoring Frontend Service..."

# Check if frontend is responding
check_frontend() {
    local response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 2>/dev/null)
    if [ "$response" = "200" ]; then
        echo "✅ Frontend is responding (HTTP $response)"
        return 0
    else
        echo "❌ Frontend not responding (HTTP $response)"
        return 1
    fi
}

# Check service status
check_service() {
    if systemctl is-active --quiet studentlink-frontend; then
        echo "✅ Frontend service is running"
        return 0
    else
        echo "❌ Frontend service is not running"
        return 1
    fi
}

# Restart frontend if needed
restart_frontend() {
    echo "🔄 Restarting frontend service..."
    systemctl restart studentlink-frontend
    sleep 10
    
    if check_service && check_frontend; then
        echo "✅ Frontend restarted successfully"
    else
        echo "❌ Frontend restart failed"
    fi
}

# Main monitoring loop
echo "Starting frontend monitoring..."
while true; do
    echo "$(date): Checking frontend..."
    
    if ! check_service || ! check_frontend; then
        echo "$(date): Frontend issue detected, restarting..."
        restart_frontend
    else
        echo "$(date): Frontend is healthy"
    fi
    
    sleep 30
done
