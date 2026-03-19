#!/bin/bash
# test_apis.sh
# Tests the service discovery system with multiple API calls
# Shows service discovery and load balancing in action

echo "Testing Service Discovery System"
echo "=================================="
echo ""

BASE_URL="http://localhost:8003"

echo "Test 1: Check Client Health"
echo "---"
echo "curl $BASE_URL/health"
curl -s $BASE_URL/health | python3 -m json.tool
echo ""
echo ""

echo "Test 2: Check Available Instances (Discovery)"
echo "---"
echo "curl http://localhost:8000/discovery/greet-service"
curl -s http://localhost:8000/discovery/greet-service | python3 -m json.tool
echo ""
echo ""

echo "Test 3-7: Call Service (5 requests - watch random load balancing)"
echo "---"
for i in {1..5}; do
  echo "Request $i:"
  echo "curl $BASE_URL/call"
  curl -s $BASE_URL/call | python3 -c "import sys, json; d=json.load(sys.stdin); print(f'  Service Instance: Port {d[\"selected_instance\"][\"port\"]}'); print(f'  Message: {d[\"service_response\"][\"message\"]}'); print(f'  Timestamp: {d[\"service_response\"][\"timestamp\"]}')"
  echo ""
done

echo ""
echo "Test 8: View Full Registry"
echo "---"
echo "curl http://localhost:8000/registry"
curl -s http://localhost:8000/registry | python3 -m json.tool
echo ""
