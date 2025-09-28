#!/bin/bash

# StudentLink Service Monitor
# This script monitors and restarts services if they fail

check_service() {
    local service_name=$1
    local port=$2
    
    if ! systemctl is-active --quiet $service_name; then
        echo "$(date): $service_name is not running, restarting..."
        systemctl restart $service_name
        sleep 5
        
        if systemctl is-active --quiet $service_name; then
            echo "$(date): $service_name restarted successfully"
        else
            echo "$(date): Failed to restart $service_name"
        fi
    fi
    
    # Check if port is listening
    if ! netstat -tlnp | grep -q ":$port "; then
        echo "$(date): Port $port is not listening for $service_name, restarting..."
        systemctl restart $service_name
        sleep 5
    fi
}

# Check services every minute
while true; do
    check_service "studentlink-backend" "8000"
    check_service "studentlink-frontend" "3000"
    sleep 60
done
