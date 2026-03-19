#!/bin/bash
# Quick test script for the microservice discovery system

echo "=========================================="
echo "Microservice Discovery System - Quick Test"
echo "=========================================="
echo ""

echo "[1] Cleaning up old processes..."
pkill -f "python3.*app.py" 2>/dev/null
sleep 2

cd /Users/samvedjoshi/Documents/273-EDS/273_Naming_ServiceDiscovery_assignment

echo "[2] Starting Service Registry..."
nohup /usr/bin/python3 service-registry/app.py > /tmp/registry.log 2>&1 &
REGISTRY_PID=$!
sleep 3

echo "[3] Starting Service A..."
nohup /usr/bin/python3 service-a/app.py > /tmp/service-a.log 2>&1 &
SERVICE_A_PID=$!
sleep 3

echo "[4] Starting Service B..."
nohup /usr/bin/python3 service-b/app.py > /tmp/service-b.log 2>&1 &
SERVICE_B_PID=$!
sleep 3

echo "[5] Starting Client..."
nohup /usr/bin/python3 client/app.py > /tmp/client.log 2>&1 &
CLIENT_PID=$!
sleep 3

echo ""
echo "=========================================="
echo "TESTING SERVICE DISCOVERY"
echo "=========================================="
echo ""

echo "Request 1:"
curl -s http://localhost:8003/call | /usr/bin/python3 -c "import sys, json; d=json.load(sys.stdin); print('✓ Response from:', d['selected_instance']['port'], '- Message:', d['service_response']['message'])" 2>/dev/null || echo "✗ Failed"

sleep 1

echo "Request 2:"
curl -s http://localhost:8003/call | /usr/bin/python3 -c "import sys, json; d=json.load(sys.stdin); print('✓ Response from:', d['selected_instance']['port'], '- Message:', d['service_response']['message'])" 2>/dev/null || echo "✗ Failed"

sleep 1

echo "Request 3:"
curl -s http://localhost:8003/call | /usr/bin/python3 -c "import sys, json; d=json.load(sys.stdin); print('✓ Response from:', d['selected_instance']['port'], '- Message:', d['service_response']['message'])" 2>/dev/null || echo "✗ Failed"

echo ""
echo "=========================================="
echo "TEST COMPLETE"
echo "=========================================="
echo ""
echo "Process IDs:"
echo "  Registry: $REGISTRY_PID"
echo "  Service A: $SERVICE_A_PID"
echo "  Service B: $SERVICE_B_PID"
echo "  Client: $CLIENT_PID"
echo ""
echo "To view logs:"
echo "  Registry: tail -f /tmp/registry.log"
echo "  Service A: tail -f /tmp/service-a.log"
echo "  Service B: tail -f /tmp/service-b.log"
echo "  Client: tail -f /tmp/client.log"
echo ""
echo "To stop all services: pkill -f 'python3.*app.py'"
