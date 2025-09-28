#!/bin/bash

# Test External Access
echo "🌐 Testing External Access..."

# Test from multiple external services
echo "=== Testing from external services ==="

# Test using curl from external
echo "1. Testing with external curl..."
curl -I http://bcpstudentlink.online 2>/dev/null | head -1 || echo "❌ External curl failed"

# Test using wget
echo "2. Testing with wget..."
wget --spider -S http://bcpstudentlink.online 2>&1 | head -3 || echo "❌ Wget failed"

# Test using telnet to port 80
echo "3. Testing port 80 connectivity..."
timeout 5 telnet bcpstudentlink.online 80 2>/dev/null | head -1 || echo "❌ Port 80 not accessible"

# Check if the issue is DNS
echo "4. Checking DNS resolution..."
nslookup bcpstudentlink.online

# Check if the issue is routing
echo "5. Checking network routing..."
traceroute -m 5 bcpstudentlink.online 2>/dev/null || echo "❌ Traceroute failed"

# Test from different user agents
echo "6. Testing with different user agents..."
curl -I -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" http://bcpstudentlink.online 2>/dev/null | head -1 || echo "❌ User agent test failed"

echo "✅ External access tests complete!"
