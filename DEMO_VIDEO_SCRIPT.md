# Demo Video Script

**Duration:** 5-7 minutes  
**Setup:** 4 terminal windows visible side-by-side

---

## INTRO (30 seconds)

**Say:**
> "Today I'm demonstrating a microservice discovery system built with Python Flask. This shows how services can automatically register themselves and clients can discover available instances for load balancing."

**Show:** Project structure in editor
```
273_Naming_ServiceDiscovery_assignment/
├── service-registry/app.py
├── service-a/app.py
├── service-b/app.py
├── client/app.py
└── README.md
```

---

## PHASE 1: START REGISTRY (1 minute)

**Terminal 1 - Registry**

**Say:**
> "First, let's start the Service Registry. This is the central hub that will track all service instances."

**Command:**
```bash
cd /Users/samvedjoshi/Documents/273-EDS/273_Naming_ServiceDiscovery_assignment
/usr/bin/python3 service-registry/app.py
```

**Wait for output:**
```
SERVICE REGISTRY STARTED
Listening on: http://localhost:8000
```

**Highlight:** "Notice it's listening on port 8000 and ready to register services."

---

## PHASE 2: START SERVICE A (1 minute)

**Terminal 2 - Service A**

**Say:**
> "Now let's start Service A. Watch what happens - it will automatically register itself with the registry."

**Command:**
```bash
/usr/bin/python3 service-a/app.py
```

**Wait for output in Terminal 2:**
```
SERVICE A STARTING
Port: 8001
[SERVICE-A] ✓ Registered with registry
[SERVICE-A] → Service ID: <uuid>
[SERVICE-A] ♥ Heartbeat sent to registry
```

**Also point to Terminal 1 (Registry):**
```
[REGISTRY] ✓ Service registered: greet-service at localhost:8001
[REGISTRY] ♥ Heartbeat received from greet-service
```

**Say:** "Perfect! Service A automatically registered with the registry. Notice the heartbeat - it sends a keep-alive signal every 3 seconds."

---

## PHASE 3: START SERVICE B (1 minute)

**Terminal 3 - Service B**

**Say:**
> "Now let's start Service B - another instance of the same service running on a different port."

**Command:**
```bash
/usr/bin/python3 service-b/app.py
```

**Wait for output in Terminal 3:**
```
SERVICE B STARTING
Port: 8002
[SERVICE-B] ✓ Registered with registry
[SERVICE-B] → Service ID: <uuid>
[SERVICE-B] ♥ Heartbeat sent to registry
```

**Point to Registry (Terminal 1):**
```
[REGISTRY] ✓ Service registered: greet-service at localhost:8002
[REGISTRY] → Total instances: 2
```

**Say:** "Excellent! Now we have 2 service instances registered. The registry knows about both. Both are sending heartbeats to prove they're alive."

---

## PHASE 4: START CLIENT (30 seconds)

**Terminal 4 - Client**

**Say:**
> "Now let's start the Client application. This will discover available services and call a random instance."

**Command:**
```bash
/usr/bin/python3 client/app.py
```

**Wait for output:**
```
CLIENT APPLICATION STARTED
Service to discover: greet-service
Registry: http://localhost:8000
Listening on: http://localhost:8003
```

**Say:** "Client is ready. Now watch the magic happen."

---

## PHASE 5: DEMONSTRATE SERVICE DISCOVERY & LOAD BALANCING (2-3 minutes)

**Terminal 4 - Make Requests**

**Say:**
> "Let's make a request to the client. The client will:"
> "1. Query the registry to discover available services"
> "2. Randomly select one instance"
> "3. Call that instance"

**Request 1:**
```bash
curl -s http://localhost:8003/call | python3 -m json.tool
```

**Watch output in Terminal 4:**
```
[CLIENT] 🚀 Starting service discovery...
[CLIENT] ✓ Found 2 instance(s)
[CLIENT]   1. localhost:8001
[CLIENT]   2. localhost:8002
[CLIENT] 🎯 Selected random instance: localhost:8002
[CLIENT] 📞 Calling service...
[CLIENT] ✓ Response received!
[CLIENT] → Message: Hello from Service B!
[CLIENT] → From: localhost:8002
```

**Point to Terminal 3 (Service B):**
```
[SERVICE-B] 📨 Serving /greet request
```

**Say:** "Perfect! Client discovered 2 instances, randomly selected Service B, and got the response. Now let's make another call."

**Request 2:**
```bash
curl -s http://localhost:8003/call | python3 -m json.tool
```

**Watch different output this time (should be different port):**
```
[CLIENT] ✓ Found 2 instance(s)
[CLIENT] 🎯 Selected random instance: localhost:8001
...
[CLIENT] → Message: Hello from Service A!
[CLIENT] → From: localhost:8001
```

**Point to Terminal 2 (Service A):**
```
[SERVICE-A] 📨 Serving /greet request
```

**Say:** "See that? This time it randomly selected Service A! This is load balancing in action."

**Request 3-5: Run rapid requests**
```bash
for i in {1..5}; do 
  echo "=== Request $i ==="
  curl -s http://localhost:8003/call | python3 -c "import sys, json; d=json.load(sys.stdin); print('Port:', d['selected_instance']['port'], '-', d['service_response']['message'])"
  sleep 1
done
```

**Say:** "Watch the ports alternate between 8001 and 8002. Each request goes to a random instance. This is client-side load balancing with service discovery!"

---

## PHASE 6: SHOW GRACEFUL DEGRADATION (Optional - 1 minute)

**Say:**
> "Let me show what happens if a service goes down. I'll stop Service B."

**In Terminal 3:** Press `Ctrl+C` to stop Service B

**Watch Registry (Terminal 1):**
```
[REGISTRY] ✗ Removed stale service: greet-service (no heartbeat)
```

**Make a request from Terminal 4:**
```bash
curl -s http://localhost:8003/call | python3 -m json.tool
```

**Show output:**
```
[CLIENT] ✓ Found 1 instance(s)
[CLIENT]   1. localhost:8001
[CLIENT] 🎯 Selected random instance: localhost:8001
```

**Say:** "See? Registry detected that Service B stopped sending heartbeats. It automatically removed it from the registry. Client continues working with just Service A. This is graceful degradation - the system continues to work even when services fail."

**Restart Service B:**
```bash
/usr/bin/python3 service-b/app.py
```

**Say:** "When Service B restarts, it automatically re-registers and is immediately available again."

---

## CLOSING (30 seconds)

**Say:**
> "That's service discovery in action. We've shown:"
> "✓ Services self-register with the registry"
> "✓ Registry monitors service health with heartbeats"
> "✓ Clients discover available instances"
> "✓ Random selection provides load balancing"
> "✓ Graceful degradation when services fail"

**Point to README:**
> "For more details, check the README and architecture documentation. This is the foundation for building scalable microservice systems. In production, you'd use a service mesh like Istio for advanced features."

**End:** "Thanks for watching!"

---

## KEY MOMENTS TO HIGHLIGHT

- ✅ Service registration (Terminal 1 shows registration messages)
- ✅ Heartbeat monitoring (Regular "♥" symbols in logs)
- ✅ Discovery query (Client shows "Found 2 instances")
- ✅ Random selection (Watch ports alternate: 8001, 8002, 8001...)
- ✅ Graceful degradation (Stop service, see it removed from registry)

## RECORDING TIPS

- **Font size:** Make terminal text large (16pt+)
- **Colors:** Use high contrast terminal theme
- **Speed:** Keep natural pace, don't rush
- **Pauses:** Pause between requests to let logs appear
- **Focus:** Use mouse to highlight key lines in logs
- **Narration:** Speak clearly and explain each step
