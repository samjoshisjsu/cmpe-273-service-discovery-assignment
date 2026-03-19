# Microservice Discovery System

A simple but complete microservice architecture demonstrating service registration, discovery, and client-side load balancing.

## Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│                  Service Registry                   │
│              (Port 8000 - Central Hub)              │
│  - Maintains registry of active services            │
│  - Handles service registration/deregistration      │
│  - Provides service discovery lookups               │
└─────────────────────────────────────────────────────┘
         ▲                    ▲                    ▲
         │ register           │ register           │
         │ heartbeat          │ heartbeat          │ discovery
         │                    │                    │
         │                    │                    │
    ┌────────────┐       ┌────────────┐       ┌──────────┐
    │ Service A  │       │ Service B  │       │  Client  │
    │ Instance 1 │       │ Instance 2 │       │          │
    │ Port 8001  │       │ Port 8002  │       │ Port 8003│
    │            │       │            │       │          │
    │ /greet     │       │ /greet     │       │ /call    │
    └────────────┘       └────────────┘       └──────────┘
           │                    │                    │
           └────────────────────┼────────────────────┘
                      Random Instance Selection
```

## Components

### 1. Service Registry (Port 8000)
Central registry that maintains:
- Active service instances and their locations
- Heartbeat monitoring for service health
- Service discovery queries

**Endpoints:**
- `POST /register` - Register a new service instance
- `GET /discovery/{service_name}` - Discover all instances of a service
- `POST /heartbeat/{service_id}` - Keep-alive signal

### 2. Service A (Port 8001) & Service B (Port 8002)
Microservices that:
- Register with the registry on startup
- Send heartbeat signals periodically
- Provide business functionality (/greet endpoint)

**Endpoints:**
- `GET /greet` - Returns a greeting message with service info

### 3. Client (Port 8003)
Client application that:
- Discovers available service instances from registry
- Selects random instance for each request (load balancing)
- Calls the selected service
- Handles service failures gracefully

**Endpoints:**
- `GET /call` - Discovers and calls random service instance

## How to Run

### 1. Install Dependencies
```bash
pip install -r requirements.txt
```

### 2. Start Service Registry
```bash
python service-registry/app.py
```

### 3. Start Service Instances (in separate terminals)
```bash
# Terminal 2
python service-a/app.py

# Terminal 3
python service-b/app.py
```

### 4. Start Client (in another terminal)
```bash
python client/app.py
```

### 5. Test the System
```bash
# Repeatedly call the client endpoint
# Each call will randomly select between Service A and B
curl http://localhost:8003/call

# You should see alternating responses from different service instances
```

## Demo Workflow

1. **Open 4 terminals** side-by-side
   
2. **Terminal 1:** Start Registry
   ```bash
   python service-registry/app.py
   ```
   
3. **Terminal 2:** Start Service A
   ```bash
   python service-a/app.py
   ```
   
4. **Terminal 3:** Start Service B
   ```bash
   python service-b/app.py
   ```
   
5. **Terminal 4:** Start Client
   ```bash
   python client/app.py
   ```

6. **Make requests** repeatedly:
   ```bash
   for i in {1..10}; do curl http://localhost:8003/call && echo ""; sleep 1; done
   ```

Watch the output and see how:
- Registry logs show service registrations
- Services log their registration and heartbeats
- Client logs show discovery and random instance selection
- Responses alternate between Service A and B

## Key Features

✅ **Service Registration** - Services self-register with the registry
✅ **Service Discovery** - Client discovers available instances
✅ **Load Balancing** - Random instance selection on each request
✅ **Heartbeat Monitoring** - Automatic removal of inactive services
✅ **Graceful Degradation** - Continues if some services are down
✅ **Demo-Friendly** - Clean logs and clear execution flow

## Technology Stack

- **Framework:** Flask (Python)
- **HTTP:** Requests library
- **Architecture:** Client-Server with Registry Pattern

## Optional: Service Mesh (Istio/Linkerd)

For production, consider implementing a service mesh like:
- **Istio** - Advanced traffic management, observability, security
- **Linkerd** - Lightweight, focused on observability and reliability

Benefits:
- Decoupled service discovery from application code
- Advanced traffic routing and load balancing
- Observability (metrics, tracing, logging)
- Security (mTLS, access policies)
- Automatic failover and retries

## Project Structure

```
273_Naming_ServiceDiscovery_assignment/
├── service-registry/
│   └── app.py              # Central registry service
├── service-a/
│   └── app.py              # Microservice instance 1
├── service-b/
│   └── app.py              # Microservice instance 2
├── client/
│   └── app.py              # Client discovering and calling services
├── requirements.txt         # Python dependencies
├── docs/
│   └── architecture.md     # Architecture details
└── README.md               # This file
```

## Notes for Demo Video

When recording the demo:
1. Show all 4 terminals running side-by-side
2. Start registry first, then services, then client
3. Make repeated requests with curl
4. Highlight in console logs:
   - Service registration messages
   - Registry maintaining instance list
   - Client discovering services
   - Alternating responses (load balancing in action)
5. Optional: Show what happens if you stop one service (graceful degradation)

---

**Author:** CMPE 273 Assignment  
**Date:** March 2026
