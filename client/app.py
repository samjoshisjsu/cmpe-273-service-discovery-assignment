"""
Client Application - Service Discovery and Load Balancing
Discovers available service instances and calls a random one
"""

from flask import Flask, jsonify
import requests
import random
import time

app = Flask(__name__)

# Configuration
REGISTRY_URL = "http://localhost:8000"
SERVICE_NAME = "greet-service"
CLIENT_PORT = 8003


def discover_service_instances():
    """
    Discover all available instances of a service from the registry
    """
    try:
        response = requests.get(
            f"{REGISTRY_URL}/discovery/{SERVICE_NAME}",
            timeout=5
        )
        
        if response.status_code == 200:
            data = response.json()
            instances = data.get('instances', [])
            return instances
        else:
            print(f"[CLIENT] Discovery failed: {response.status_code}")
            return []
            
    except Exception as e:
        print(f"[CLIENT] Error: {str(e)}")
        return []


def call_service_instance(instance):
    """
    Call a specific service instance
    """
    try:
        url = f"http://{instance['host']}:{instance['port']}/greet"
        response = requests.get(url, timeout=5)
        
        if response.status_code == 200:
            return response.json()
        else:
            print(f"[CLIENT] Service call failed: {response.status_code}")
            return None
            
    except Exception as e:
        print(f"[CLIENT] Error: {str(e)}")
        return None


@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({'status': 'healthy', 'service': 'client'}), 200


@app.route('/call', methods=['GET'])
def call():
    """
    Main endpoint: Discover service instances and call a random one
    """
    print("[CLIENT] Discovering services...")
    
    # Step 1: Discover available instances
    instances = discover_service_instances()
    
    if not instances:
        print("[CLIENT] No instances found")
        return jsonify({
            'error': 'No service instances available',
            'service': SERVICE_NAME
        }), 503
    
    print(f"[CLIENT] Found {len(instances)} instance(s)")
    
    # Step 2: Select random instance
    selected_instance = random.choice(instances)
    print(f"[CLIENT] Calling port {selected_instance['port']}")
    
    # Step 3: Call the selected instance
    result = call_service_instance(selected_instance)
    
    if result:
        print(f"[CLIENT] Response: {result['message']}")
        
        return jsonify({
            'success': True,
            'selected_instance': selected_instance,
            'service_response': result
        }), 200
    else:
        print("[CLIENT] Failed to call service")
        
        return jsonify({
            'success': False,
            'error': 'Failed to call service',
            'selected_instance': selected_instance
        }), 503


@app.route('/stats', methods=['GET'])
def stats():
    """Get discovery stats"""
    instances = discover_service_instances()
    
    return jsonify({
        'service_name': SERVICE_NAME,
        'available_instances': len(instances),
        'instances': instances
    }), 200


if __name__ == '__main__':
    print("CLIENT")
    print(f"Port: {CLIENT_PORT}")
    print("")
    
    app.run(host='localhost', port=CLIENT_PORT, debug=False)
