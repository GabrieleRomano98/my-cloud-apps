# 🚀 Deploy to Google Cloud Run via UI - Complete Guide

This guide shows you how to deploy all your projects using **only** the Google Cloud Console UI - no command line needed!

---

## 📋 Table of Contents
1. [Initial Setup (One-Time)](#initial-setup-one-time)
2. [Deploy a Project](#deploy-a-project)
3. [Update a Project](#update-a-project)
4. [Monitor Usage](#monitor-usage)
5. [Troubleshooting](#troubleshooting)

---

## Initial Setup (One-Time)

### Step 1: Create Google Cloud Account
1. Go to: https://cloud.google.com/
2. Click **Get Started for Free**
3. Sign in with your Google account
4. Enter payment details (you won't be charged if you stay in free tier)
5. You'll get $300 in free credits for 90 days

### Step 2: Create a Project
1. Go to: https://console.cloud.google.com/
2. Click the **project dropdown** at the top
3. Click **New Project**
4. Enter:
   - **Project name:** `my-cloud-apps` (or your choice)
   - **Project ID:** Will be auto-generated (note this down!)
   - **Location:** Leave default
5. Click **Create**
6. Wait ~30 seconds for project to be created
7. Make sure your new project is selected in the dropdown

### Step 3: Enable Required APIs
1. Go to: https://console.cloud.google.com/apis/library
2. Search for and enable these APIs:
   - **Cloud Run Admin API** - Search "Cloud Run Admin API", click **Enable**
   - **Cloud Build API** - Search "Cloud Build API", click **Enable**
   - **Artifact Registry API** - Search "Artifact Registry API", click **Enable**
3. Wait for each to activate (~1 minute each)

**Note:** You may also see prompts to enable these APIs automatically when you first use Cloud Run - you can enable them then as well.

### Step 4: Set Up Billing Budget (Important!)
1. Go to: https://console.cloud.google.com/billing/budgets
2. Click **Create Budget**
3. Enter:
   - **Name:** "Monthly Budget Alert"
   - **Budget amount:** $5.00
   - **Threshold rules:** 
     - Add: 50% ($2.50)
     - Add: 90% ($4.50)
     - Add: 100% ($5.00)
4. **Email alerts:** Check your email
5. Click **Finish**
6. You'll get alerts if costs approach $5 (unlikely with free tier!)

✅ **Initial setup complete!** You only need to do this once.

---

## Deploy a Project

### Method A: Deploy from GitHub (Recommended)

#### Step 1: Connect GitHub Repository
1. Go to: https://console.cloud.google.com/run
2. Click **Create Service**
3. Select **Continuously deploy from a repository**
4. Click **Set up with Cloud Build**

#### Step 2: Authorize GitHub
1. Click **Manage connected repositories**
2. Click **Connect repository**
3. Select **GitHub**
4. Authorize Google Cloud Build to access GitHub
5. Select your repository: `GabrieleRomano98/SpotAI`
6. Click **Connect**

#### Step 3: Configure Build
1. **Branch:** `^master$` (or `^main$`)
2. **Build type:** Select **Dockerfile**
3. **Source location:** `/Dockerfile`
4. Click **Save**

#### Step 4: Configure Service Settings
1. **Service name:** `spotai` (lowercase, no spaces)
2. **Region:** `us-central1` (Iowa) - Free tier eligible
3. **Authentication:** Select **Allow unauthenticated invocations**

**Note:** If prompted to enable additional APIs (like Cloud Run Admin API), click **Enable** and wait ~30 seconds.

#### Step 5: Configure Container Settings
1. Click **Container, Variables & Secrets, Connections**
2. **Container port:** `8080`
3. Under **Resources:**
   - **Memory:** `512 MiB` (minimum for free tier)
   - **CPU:** `1` (minimum)
   - **Request timeout:** `300` seconds
4. Under **Autoscaling:**
   - **Minimum instances:** `0` (scale to zero = free!)
   - **Maximum instances:** `1` (⚠️ **Important for Socket.IO apps!**)
     - SpotAI uses Socket.IO which keeps connection state in memory
     - Multiple instances = users on different instances won't see each other
     - Set to `1` for small-scale use, or use Redis for multi-instance (advanced)
5. Under **CPU allocation:**
   - Select **CPU is only allocated during request processing** ✅

**About "Stateless HTTP":**
- Don't worry! Cloud Run fully supports WebSockets (which Socket.IO uses)
- "Stateless" just means containers can scale up/down
- Your Socket.IO connections will work perfectly
- HTTPS is automatically enabled (free SSL certificate included!)

**Note:** If your app becomes very popular, you may need to implement Redis for shared state across multiple instances, but for starting out, `max-instances: 1` works great!

#### Step 6: Deploy!
1. Scroll down and click **Create**
2. Wait 3-5 minutes for deployment
3. You'll see a green checkmark when ready
4. Your URL will be: `https://spotai-XXXXX-uc.a.run.app`

✅ **Project deployed!**

---

### 🔒 About HTTPS and WebSockets

**HTTPS is automatically enabled!**
- Every Cloud Run service gets a free SSL certificate
- Your URL will be: `https://spotai-xxxxx-uc.a.run.app` (note the `https://`)
- No configuration needed - it just works!
- Certificate auto-renews, zero maintenance

**WebSockets work perfectly!**
- Despite being called "stateless HTTP", Cloud Run fully supports WebSockets
- Your Socket.IO connections will work seamlessly
- Connections upgrade from HTTP to WebSocket automatically
- No special configuration needed

**Security features included:**
- ✅ Free SSL/TLS certificate (HTTPS)
- ✅ Automatic certificate renewal
- ✅ WebSocket support (for Socket.IO)
- ✅ DDoS protection
- ✅ Global load balancing

---

### Method B: Deploy from Local Files (Alternative)

If you prefer to upload files directly:

#### Step 1: Prepare Files
1. Make sure your project has a `Dockerfile`
2. Zip your project folder (excluding `node_modules`, `.git`)

#### Step 2: Upload to Cloud Build
1. Go to: https://console.cloud.google.com/cloud-build/builds
2. Click **Create Trigger**
3. Select **Manual invocation**
4. Upload your zip file
5. Follow steps 4-6 from Method A above

---

## Update a Project

### If Using GitHub Integration (Automatic):
1. Make changes to your code locally
2. Commit and push to GitHub:
   ```bash
   git add .
   git commit -m "Update feature"
   git push
   ```
3. Cloud Build automatically detects the push
4. New version deploys automatically in 3-5 minutes
5. Check status: https://console.cloud.google.com/cloud-build/builds

### Manual Redeploy via UI:
1. Go to: https://console.cloud.google.com/run
2. Click on your service (`spotai`)
3. Click **Edit & Deploy New Revision**
4. Make any changes needed
5. Click **Deploy**
6. Wait 2-3 minutes for new revision

---

## Monitor Usage

### Check Service Status
1. Go to: https://console.cloud.google.com/run
2. You'll see all your services:
   - **Service name**
   - **URL** (click to open)
   - **Region**
   - **Last deployed**
   - **Status** (green = healthy)

### View Metrics
1. Click on a service (e.g., `spotai`)
2. Click **Metrics** tab
3. See:
   - **Request count** - How many requests
   - **Request latency** - Response time
   - **Container instances** - How many running
   - **Billable container time** - What you're charged for

### Check Costs
1. Go to: https://console.cloud.google.com/billing
2. Click **Reports**
3. Filter by:
   - **Service:** Cloud Run
   - **Time range:** Current month
4. See exact costs (usually $0.00!)

### View Logs
1. Go to: https://console.cloud.google.com/run
2. Click on your service
3. Click **Logs** tab
4. See real-time application logs
5. Filter by:
   - Time range
   - Severity (Info, Warning, Error)
   - Custom text search

---

## Free Tier Limits Reference

| Resource | Free Tier Limit | What It Means |
|----------|----------------|---------------|
| Requests | 2,000,000/month | API calls to your apps |
| Memory | 360,000 GB-seconds | Total memory used |
| CPU | 180,000 vCPU-seconds | Total processing time |
| Network | 1 GB/month | Data sent from apps (North America) |

**Translation:** You can run 3-5 small apps with moderate traffic completely free!

---

## Troubleshooting

### Build Failed
**Problem:** Red X on deployment, says "Build failed"

**Solutions:**
1. Check **Logs** tab for error details
2. Common issues:
   - Missing `Dockerfile` - Make sure it exists in repo root
   - Docker syntax error - Validate Dockerfile locally
   - Missing dependencies - Check `package.json` files
3. Fix the issue, push to GitHub, it will retry automatically

### Service Unavailable (502/503 errors)
**Problem:** URL shows error page

**Solutions:**
1. Check **Logs** for application errors
2. Verify:
   - Port is set to `8080` in service settings
   - App listens on `process.env.PORT` or `8080`
   - `NODE_ENV=production` is set (automatic in Cloud Run)
3. Check **Metrics** - Is container crashing?

### "Permission Denied"
**Problem:** Can't access deployment settings

**Solutions:**
1. Make sure you're the project owner
2. Go to: https://console.cloud.google.com/iam-admin/iam
3. Check your email has "Owner" or "Editor" role

### Exceeded Free Tier
**Problem:** Got a bill or warning

**Solutions:**
1. Check which service used most resources
2. Reduce **Maximum instances** to 5 or fewer
3. Ensure **Minimum instances** is `0` (scale to zero)
4. Delete unused services:
   - Go to: https://console.cloud.google.com/run
   - Select service → **Delete**

---

## Deploy Multiple Projects (Scaling Up)

### Adding Your Second Project
1. Push new project to GitHub (separate repo or monorepo)
2. Go to: https://console.cloud.google.com/run
3. Click **Create Service**
4. Follow same steps as "Deploy a Project" above
5. Use different service name: `project2`
6. Both projects share the same free tier limits

### Managing 3+ Projects
All projects in same Google Cloud Project share resources:
- Total: 2M requests/month across all apps
- Each app scales to zero independently
- Monitor combined usage in billing dashboard

**Example Setup:**
```
Google Cloud Project: "my-cloud-apps"
├── Service: spotai (500K requests/month)
├── Service: my-blog (300K requests/month)
└── Service: todo-app (200K requests/month)
Total: 1M requests/month - Still free! ✅
```

---

## Quick Reference

### Key URLs
- **Cloud Run Console:** https://console.cloud.google.com/run
- **Cloud Build:** https://console.cloud.google.com/cloud-build/builds
- **Billing:** https://console.cloud.google.com/billing
- **Logs:** https://console.cloud.google.com/logs

### Recommended Settings for Free Tier
```
Memory: 512 MiB
CPU: 1
Min instances: 0
Max instances: 10
Request timeout: 300 seconds
CPU allocation: During request processing only ✓
Authentication: Allow unauthenticated ✓
```

---

## Next Steps

✅ Deploy SpotAI following this guide  
✅ Set up budget alerts  
✅ Test your live URL  
✅ Monitor usage for first week  
✅ Add more projects as needed  

---

**Need Help?**
- Google Cloud Run Docs: https://cloud.google.com/run/docs
- Community: https://stackoverflow.com/questions/tagged/google-cloud-run

---

*Last updated: February 2026*
