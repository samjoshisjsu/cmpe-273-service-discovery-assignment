#!/bin/bash
# start_services.sh
# Starts all microservices: Registry, Service A, Service B, and Client
# This script starts each service in a separate background process

echo "Starting Microservice Discovery System..."
echo ""

# Kill any existing processes
echo "[1] Cleaning up old processes..."
pkill -f "python3.*app.py" 2>/dev/null
sleep 1

cd /Users/samvedjoshi/Documents/273-EDS/273_Naming_ServiceDiscovery_assignment

# Start Service Registry
echo "[2] Starting Service Registry (Port 8000)..."
nohup /usr/bin/python3 service-registry/app.py > /tmp/registry.log 2>&1 &
REGISTRY_PID=$!
echo "    Registry PID: $REGISTRY_PID"
sleep 2

# Start Service A
echo "[3] Starting Service A (Port 8001)..."
nohup /usr/bin/python3 service-a/app.py > /tmp/service-a.log 2>&1 &
SERVICE_A_PID=$!
echo "    Service A PID: $SERVICE_A_PID"
sleep 2

# Start Service B
echo "[4] Starting Service B (Port 8002)..."
nohup /usr/bin/python3 service-b/app.py > /tmp/service-b.log 2>&1 &
SERVICE_B_PID=$!
echo "    Service B PID: $SERVICE_B_PID"
sleep 2

# Start Client
echo "[5] Starting Client (Port 8003)..."
nohup /usr/bin/python3 client/app.py > /tmp/client.log 2>&1 &
CLIENT_PID=$!
echo "    Client PID: $CLIENT_PID"
sleep 2

echo ""
echo "=========================================="
echo "All services started successfully!"
echo "=========================================="
echo ""
echo "Service Details:"
echo "  Registry:  http://localhost:8000"
echo "  Service A: http://localhost:8001"
echo "  Service B: http://localhost:8002"
echo "  Client:    http://localhost:8003"
echo ""
echo "View logs with:"
echo "  tail -f /tmp/registry.log"
echo "  tail -f /tmp/service-a.log"
echo "  tail -f /tmp/service-b.log"
echo "  tail -f /tmp/client.log"
echo ""
echo "Run API tests with:"
echo "  bash test_apis.sh"
echo ""
echo "Stop all services with:"
echo "  pkill -f 'python3.*app.py'"
echo ""
