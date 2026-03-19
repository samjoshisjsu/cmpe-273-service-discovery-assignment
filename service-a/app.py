"""
Microservice A - Service Instance 1
Registers with registry, provides business logic, sends heartbeats
"""

from flask import Flask, jsonify
import requests
import threading
import time
import os

app = Flask(__name__)

# Configuration
SERVICE_NAME = "greet-service"
SERVICE_HOST = "localhost"
SERVICE_PORT = 8001
REGISTRY_URL = "http://localhost:8000"
HEARTBEAT_INTERVAL = 3  # seconds

# Global variable to store service ID
service_id = None


def register_with_registry():
    """Register this service with the registry"""
    global service_id
    
    try:
        response = requests.post(
            f"{REGISTRY_URL}/register",
            json={
                "service_name": SERVICE_NAME,
                "host": SERVICE_HOST,
                "port": SERVICE_PORT
            },
            headers={'Content-Type': 'application/json'},
            timeout=5
        )
        
        if response.status_code == 200:
            service_id = response.json()['service_id']
            print(f"[SERVICE-A] Registered with registry")
        else:
            print(f"[SERVICE-A] Registration failed: {response.status_code}")
            
    except Exception as e:
        print(f"[SERVICE-A] Error: {str(e)}")


def send_heartbeat():
    """Periodically send heartbeat to registry"""
    while True:
        time.sleep(HEARTBEAT_INTERVAL)
        
        if service_id is None:
            continue
            
        try:
            response = requests.post(
                f"{REGISTRY_URL}/heartbeat/{service_id}",
                timeout=5
            )
            
            if response.status_code == 200:
                print(f"[SERVICE-A] Heartbeat sent")
            else:
                print(f"[SERVICE-A] Heartbeat failed: {response.status_code}")
                
        except Exception as e:
            print(f"[SERVICE-A] Error: {str(e)}")


@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({'status': 'healthy', 'service': 'service-a'}), 200


@app.route('/greet', methods=['GET'])
def greet():
    """
    Main business logic endpoint
    Returns a greeting with service information
    """
    response = {
        'message': 'Hello from Service A!',
        'service_id': service_id,
        'service_name': SERVICE_NAME,
        'instance': f"{SERVICE_HOST}:{SERVICE_PORT}",
        'timestamp': time.time()
    }
    
    print(f"[SERVICE-A] Serving /greet")
    
    return jsonify(response), 200


if __name__ == '__main__':
    print("SERVICE A")
    print(f"Port: {SERVICE_PORT}")
    print("")
    
    # Register with registry
    register_with_registry()
    
    # Start heartbeat thread
    heartbeat_thread = threading.Thread(target=send_heartbeat, daemon=True)
    heartbeat_thread.start()
    
    # Start Flask app
    app.run(host=SERVICE_HOST, port=SERVICE_PORT, debug=False)
