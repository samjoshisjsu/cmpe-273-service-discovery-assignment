"""
Service Registry - Central Hub for Service Discovery
Maintains a registry of active service instances and their locations.
"""

from flask import Flask, request, jsonify
from datetime import datetime, timedelta
import uuid
import json
import logging

# Suppress Flask logging
log = logging.getLogger('werkzeug')
log.setLevel(logging.ERROR)

app = Flask(__name__)
app.config['JSON_SORT_KEYS'] = False

# In-memory registry of services
# Structure: { service_id: { 'service_name': str, 'host': str, 'port': int, 'last_heartbeat': datetime } }
registry = {}

# Configuration
HEARTBEAT_TIMEOUT = 10  # seconds - services must heartbeat within this time


@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({'status': 'healthy', 'service': 'registry'}), 200


@app.route('/register', methods=['POST'])
def register():
    """
    Register a new service instance
    
    Expected JSON body:
    {
        "service_name": "service-a",
        "host": "localhost",
        "port": 5001
    }
    """
    try:
        data = request.get_json(force=True)
        
        # Validate required fields
        if not data or not all(k in data for k in ['service_name', 'host', 'port']):
            return jsonify({'error': 'Missing required fields'}), 400
        
        # Generate unique service ID
        service_id = str(uuid.uuid4())
        
        # Store in registry
        registry[service_id] = {
            'service_name': data['service_name'],
            'host': data['host'],
            'port': data['port'],
            'last_heartbeat': datetime.now(),
            'registered_at': datetime.now()
        }
        
        print(f"[REGISTRY] Registered {data['service_name']} at {data['host']}:{data['port']}")
        print(f"[REGISTRY] Total instances: {len(registry)}")
        
        return jsonify({
            'service_id': service_id,
            'message': 'Service registered successfully'
        }), 200
        
    except Exception as e:
        print(f"[REGISTRY] Error: {str(e)}")
        return jsonify({'error': str(e)}), 400


@app.route('/heartbeat/<service_id>', methods=['POST'])
def heartbeat(service_id):
    """
    Update heartbeat for a service instance (keep-alive signal)
    """
    if service_id not in registry:
        return jsonify({'error': 'Service not found'}), 404
    
    registry[service_id]['last_heartbeat'] = datetime.now()
    print(f"[REGISTRY] Heartbeat from {registry[service_id]['service_name']}")
    
    return jsonify({'status': 'heartbeat acknowledged'}), 200


@app.route('/discovery/<service_name>', methods=['GET'])
def discovery(service_name):
    """
    Discover all active instances of a service
    
    Returns:
    {
        "service_name": "service-a",
        "instances": [
            {
                "service_id": "uuid",
                "host": "localhost",
                "port": 5001
            }
        ]
    }
    """
    # Clean up stale services (no heartbeat for HEARTBEAT_TIMEOUT seconds)
    now = datetime.now()
    stale_services = []
    
    for sid, info in list(registry.items()):
        if (now - info['last_heartbeat']).total_seconds() > HEARTBEAT_TIMEOUT:
            stale_services.append(sid)
    
    # Remove stale services
    for sid in stale_services:
        service_info = registry.pop(sid)
        print(f"[REGISTRY] Removed {service_info['service_name']} (no heartbeat)")
    
    # Find all instances of the requested service
    instances = []
    for service_id, info in registry.items():
        if info['service_name'] == service_name:
            instances.append({
                'service_id': service_id,
                'host': info['host'],
                'port': info['port']
            })
    
    print(f"[REGISTRY] Discovery: {service_name} - {len(instances)} instance(s)")
    
    return jsonify({
        'service_name': service_name,
        'instances': instances
    }), 200


@app.route('/registry', methods=['GET'])
def get_registry():
    """
    Debug endpoint: View entire registry
    """
    registry_info = {}
    for sid, info in registry.items():
        registry_info[sid] = {
            'service_name': info['service_name'],
            'host': info['host'],
            'port': info['port'],
            'registered_at': info['registered_at'].isoformat(),
            'last_heartbeat': info['last_heartbeat'].isoformat()
        }
    
    return jsonify(registry_info), 200


if __name__ == '__main__':
    print("SERVICE REGISTRY")
    print("Listening on: http://localhost:8000")
    print("")
    
    app.run(host='localhost', port=8000, debug=False)
