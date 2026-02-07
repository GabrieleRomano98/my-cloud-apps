# ❓ Frequently Asked Questions

Common questions about deploying to Google Cloud Run.

---

## About "Stateless HTTP" and WebSockets

### Q: Cloud Run says "stateless HTTP" - will Socket.IO work?

**A: Yes, Socket.IO works perfectly!** ✅

Despite the name "stateless HTTP", Cloud Run fully supports WebSocket connections:
- Socket.IO establishes WebSocket connections automatically
- Connections upgrade from HTTP to WebSocket seamlessly
- Your real-time game features will work as expected
- No special configuration needed

**"Stateless" just means:**
- Containers can scale up and down dynamically
- Each container runs independently
- You shouldn't rely on local file storage (use databases for persistence)

**For Socket.IO apps like SpotAI:**
- Set `max-instances: 1` to keep all users on the same container
- This ensures all players can see each other's game rooms
- For scaling beyond 1 instance, you'd need Redis (advanced)

---

## About HTTPS

### Q: Will HTTPS be enabled automatically?

**A: Yes, HTTPS is automatic and free!** ✅

Every Cloud Run service gets:
- **Free SSL/TLS certificate** - Automatically provisioned
- **Automatic renewal** - Zero maintenance
- **HTTPS by default** - Your URL will be `https://...`
- **No configuration needed** - It just works!

Your deployed URL will look like:
```
https://spotai-abc123xyz-uc.a.run.app
```

**Benefits:**
- ✅ Secure connections (encryption)
- ✅ Works with all modern browsers
- ✅ Required for many browser features (geolocation, notifications, etc.)
- ✅ Better SEO ranking
- ✅ User trust (no "Not Secure" warnings)

---

## About Multiple Instances

### Q: Why should I set max-instances to 1 for SpotAI?

**A: Because Socket.IO keeps game state in memory.**

**The problem with multiple instances:**
```
User A connects to → Instance 1 → Creates room "ABC123"
User B connects to → Instance 2 → Can't see room "ABC123"
```

Each container instance has its own memory and Socket.IO state. Users on different instances can't interact.

**Solutions:**

**Option 1: Single Instance (Recommended for Starting Out)**
```json
"maxInstances": 1
```
- All users connect to the same container
- Everyone sees all rooms
- Simple, no extra code needed
- Good for up to ~100 concurrent users

**Option 2: Redis for Shared State (Advanced)**
```javascript
// In server/index.js
const { createAdapter } = require('@socket.io/redis-adapter');
const { createClient } = require('redis');

const pubClient = createClient({ url: REDIS_URL });
const subClient = pubClient.duplicate();

io.adapter(createAdapter(pubClient, subClient));
```
- Requires Redis instance (Google Cloud Memorystore)
- More complex setup
- Can scale to hundreds of instances
- Costs money for Redis

**For most use cases, max-instances: 1 is perfect!**

---

## About Costs

### Q: Will I be charged for using Cloud Run?

**A: Not if you stay within free tier limits!** ✅

**Free tier includes (per month):**
- 2 million requests
- 360,000 GB-seconds of memory
- 180,000 vCPU-seconds
- 1 GB network egress (North America)

**For SpotAI with moderate usage:**
```
~50,000 requests/month
~10-20 concurrent users
~5-10 active rooms

Result: $0.00/month ✅
```

**Key settings to stay free:**
- `min-instances: 0` (scale to zero when not in use)
- `max-instances: 1` (limit scaling)
- `memory: 512Mi` (minimum)
- `region: us-central1` (free tier eligible)

**Even if you exceed:**
```
3 million requests (1M over free tier)
Cost: 1M × $0.40 = $0.40/month

Still very cheap! 🎉
```

---

## About Deployment Method

### Q: Do I need to use command line (gcloud CLI)?

**A: No! You can deploy entirely via the UI.** ✅

This repository is set up for **UI-based deployment**:
1. Open Google Cloud Console in browser
2. Click through the UI to create service
3. Connect your GitHub repository
4. Configure settings (memory, instances, etc.)
5. Click Deploy
6. Done!

**No command line knowledge required.**

See [DEPLOY_GUIDE.md](./DEPLOY_GUIDE.md) for complete step-by-step instructions with screenshots references.

---

## About Updates

### Q: How do I update my deployed app after making changes?

**A: Just push to GitHub - it auto-deploys!** ✅

If you enabled GitHub integration:
```bash
# 1. Make changes to your code
# 2. Commit and push
git add .
git commit -m "Update feature"
git push

# 3. Cloud Run automatically rebuilds and deploys
# 4. New version live in 3-5 minutes
```

**Manual update via UI:**
1. Go to: https://console.cloud.google.com/run
2. Click on your service
3. Click **Edit & Deploy New Revision**
4. Click **Deploy**
5. Wait 2-3 minutes

---

## About Cold Starts

### Q: What is a "cold start" and will it affect my app?

**A: First request after idle takes 1-2 seconds. After that, instant!**

**What happens:**
```
1. No traffic for ~15 minutes → Container scales to zero
2. New request arrives → Container starts (cold start: 1-2 seconds)
3. Subsequent requests → Instant (container is warm)
```

**For SpotAI:**
- First user to visit might wait 1-2 seconds
- After that, all users get instant responses
- Not noticeable for most users

**To avoid cold starts (costs money):**
```json
"minInstances": 1  // Keep one container always running
```
But this costs ~$5-10/month, so only do this if cold starts are a real problem.

---

## About Domains

### Q: Can I use my own domain name?

**A: Yes, but it requires DNS setup.**

**Steps:**
1. Go to Cloud Run → Your service → **Manage Custom Domains**
2. Click **Add Mapping**
3. Enter your domain: `spotai.yoursite.com`
4. Follow instructions to update your DNS records
5. Wait 15-60 minutes for propagation

**Requirements:**
- You own a domain name
- Access to DNS settings (usually at your domain registrar)

**Free options for domains:**
- Freenom (free domains)
- Your existing domain with subdomain (e.g., `apps.yoursite.com/spotai`)

See: https://cloud.google.com/run/docs/mapping-custom-domains

---

## About Environment Variables

### Q: How do I add environment variables (API keys, etc.)?

**A: Via Cloud Run UI:**

1. Go to: https://console.cloud.google.com/run
2. Click your service
3. Click **Edit & Deploy New Revision**
4. Click **Variables & Secrets** tab
5. Click **Add Variable**
6. Enter:
   - **Name:** `API_KEY`
   - **Value:** `your-secret-key`
7. Click **Deploy**

**In your code:**
```javascript
const apiKey = process.env.API_KEY;
```

**For sensitive data (recommended):**
Use Secret Manager instead:
1. Store secret in Secret Manager
2. Reference it in Cloud Run
3. More secure than plain environment variables

---

## About Logs

### Q: How do I view logs and debug issues?

**A: Via Cloud Run UI:**

1. Go to: https://console.cloud.google.com/run
2. Click your service
3. Click **Logs** tab
4. See real-time logs from your application

**Filter logs:**
- By severity (Info, Warning, Error)
- By time range
- By custom text search

**In your code:**
```javascript
console.log('Info message');
console.error('Error message');
console.warn('Warning message');
```

All appear in Cloud Run logs automatically!

---

## About Database

### Q: Where should I store persistent data?

**A: Use a database service, not local files.**

Cloud Run containers are ephemeral - files don't persist when containers restart.

**Options:**

**Free/Cheap:**
- **MongoDB Atlas** - Free tier: 512MB
- **Supabase** - Free tier with PostgreSQL
- **Google Firestore** - NoSQL, generous free tier
- **Google Cloud SQL** - Managed PostgreSQL/MySQL (costs money)

**For SpotAI:**
Currently uses in-memory storage (rooms stored in `Map`):
- Works fine with `max-instances: 1`
- Data lost when container restarts
- Fine for temporary game rooms
- For persistent rooms, add a database

---

## About Monitoring

### Q: How do I monitor my app's performance?

**A: Cloud Run provides built-in monitoring:**

1. Go to: https://console.cloud.google.com/run
2. Click your service
3. Click **Metrics** tab

**See:**
- Request count
- Request latency (response time)
- Container instances (how many running)
- CPU utilization
- Memory utilization
- Error rate

**Set up alerts:**
1. Click **Create Alert** 
2. Choose metric (e.g., error rate > 5%)
3. Enter email for notifications

---

## About Multiple Projects

### Q: Can I deploy multiple apps from this repository?

**A: Yes! That's exactly what this is for.** ✅

**Add a new project:**
```bash
# 1. Clone your new project
cd projects
git clone https://github.com/YourUser/NewApp.git newapp

# 2. Add to deploy-config.json
{
  "name": "newapp",
  "displayName": "My New App",
  "path": "projects/newapp",
  "serviceName": "newapp",
  "repository": "https://github.com/YourUser/NewApp.git"
}

# 3. Deploy via UI (same process as SpotAI)
```

**All projects share the free tier:**
- Total: 2M requests/month across all apps
- Each app scales independently
- Monitor combined usage in billing dashboard

See [MULTI_PROJECT_SETUP.md](./MULTI_PROJECT_SETUP.md) for details.

---

## Still Have Questions?

- **Check:** [DEPLOY_GUIDE.md](./DEPLOY_GUIDE.md) - Complete walkthrough
- **Check:** [FREE_TIER_TIPS.md](./FREE_TIER_TIPS.md) - Cost optimization
- **Search:** [Stack Overflow - google-cloud-run](https://stackoverflow.com/questions/tagged/google-cloud-run)
- **Read:** [Official Cloud Run Docs](https://cloud.google.com/run/docs)

---

*Last updated: February 2026*
