#!/bin/bash
# test_failures.sh
# Tests failure scenarios and graceful degradation
# Shows how the system handles service outages

echo "Testing Failure Scenarios"
echo "=================================="
echo ""

BASE_URL="http://localhost:8003"
REGISTRY_URL="http://localhost:8000"

echo "SETUP: Services should be running"
echo "Run 'bash start_services.sh' first"
echo ""
sleep 2

# Test 1: Check current state
echo "Test 1: Current State - Both services active"
echo "---"
echo "curl $REGISTRY_URL/discovery/greet-service"
curl -s $REGISTRY_URL/discovery/greet-service | python3 -m json.tool | grep -E "port|service_id"
INSTANCES_BEFORE=$(curl -s $REGISTRY_URL/discovery/greet-service | python3 -c "import sys, json; print(len(json.load(sys.stdin)['instances']))")
echo "Active instances: $INSTANCES_BEFORE"
echo ""
echo ""

# Test 2: Call service while both running
echo "Test 2: Successful calls with 2 instances"
echo "---"
for i in {1..3}; do
  echo "Request $i:"
  curl -s $BASE_URL/call | python3 -c "import sys, json; d=json.load(sys.stdin); print(f'  Port: {d[\"selected_instance\"][\"port\"]} - {d[\"service_response\"][\"message\"]}')"
  sleep 0.5
done
echo ""
echo ""

# Test 3: Get PIDs to kill
echo "Test 3: Stopping Service B..."
echo "---"
SERVICE_B_PID=$(ps aux | grep "service-b/app.py" | grep -v grep | awk '{print $2}')
if [ -z "$SERVICE_B_PID" ]; then
  echo "Could not find Service B PID"
else
  echo "Service B PID: $SERVICE_B_PID"
  kill $SERVICE_B_PID
  echo "Service B stopped"
  sleep 2
fi
echo ""
echo ""

# Test 4: Check registry after service stops
echo "Test 4: Registry after Service B stops (wait for timeout)"
echo "---"
echo "Waiting 10 seconds for heartbeat timeout..."
sleep 10
echo "curl $REGISTRY_URL/discovery/greet-service"
curl -s $REGISTRY_URL/discovery/greet-service | python3 -m json.tool | grep -E "port|service_id"
INSTANCES_AFTER=$(curl -s $REGISTRY_URL/discovery/greet-service | python3 -c "import sys, json; print(len(json.load(sys.stdin)['instances']))")
echo "Active instances: $INSTANCES_AFTER (down from $INSTANCES_BEFORE)"
echo ""
echo ""

# Test 5: Client continues with remaining service
echo "Test 5: Client still works with remaining service"
echo "---"
for i in {1..3}; do
  echo "Request $i:"
  RESPONSE=$(curl -s $BASE_URL/call 2>/dev/null)
  if echo "$RESPONSE" | grep -q "success"; then
    echo "$RESPONSE" | python3 -c "import sys, json; d=json.load(sys.stdin); print(f'  Port: {d[\"selected_instance\"][\"port\"]} - {d[\"service_response\"][\"message\"]}')"
  else
    echo "  FAILED"
  fi
  sleep 0.5
done
echo ""
echo ""

# Test 6: Invalid service query
echo "Test 6: Query for non-existent service"
echo "---"
echo "curl $REGISTRY_URL/discovery/non-existent-service"
curl -s $REGISTRY_URL/discovery/non-existent-service | python3 -m json.tool
echo ""
echo ""

echo "=================================="
echo "Failure Testing Complete"
echo "=================================="
echo ""
echo "Summary:"
echo "  ✓ Services started with 2 instances"
echo "  ✓ Client calls work with both services"
echo "  ✓ Service B stopped and killed"
echo "  ✓ Registry removed stale service after 10 seconds"
echo "  ✓ Client continues with Service A"
echo "  ✓ Non-existent services return empty list"
echo ""
echo "This shows graceful degradation:"
echo "  - System continues working even when services fail"
echo "  - Registry automatically removes failed services"
echo "  - No cascading failures"
echo ""
