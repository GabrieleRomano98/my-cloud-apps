# 💰 Free Tier Tips - Stay at $0/month

Quick tips to ensure you never get charged while running multiple projects on Google Cloud Run.

---

## ✅ Golden Rules

### 1. Always Scale to Zero
- **Minimum instances:** `0`
- This means containers stop when no traffic
- **Saves:** ~70% of potential costs
- **Trade-off:** First request after idle takes 1-2 seconds (cold start)

### 2. Use Minimum Resources
- **Memory:** `512 MiB` (minimum)
- **CPU:** `1` (minimum)
- Only increase if you see performance issues

### 3. CPU Only During Requests
- Select: **"CPU is only allocated during request processing"**
- **Saves:** ~50% on CPU costs
- No downside for typical web apps

### 4. Limit Max Instances
- **Maximum instances:** `1` for Socket.IO apps (SpotAI)
- **Maximum instances:** `10` or less for stateless apps
- Prevents runaway scaling if app goes viral
- Can always increase later if needed

**⚠️ Important for Socket.IO Apps (like SpotAI):**
- Socket.IO keeps connection state in memory
- Multiple instances = users connect to different instances
- Users on different instances won't see each other's game rooms!
- **Solution:** Set max-instances to `1` for simple deployment
- **Advanced:** Use Redis for shared state if you need to scale beyond 1 instance

### 5. Choose Free Tier Region
- **Best:** `us-central1` (Iowa)
- **Also good:** `us-east1`, `us-west1`
- Avoid: European and Asian regions (higher egress costs)

---

## 📊 Capacity Planning

### What You Can Run for Free

**Scenario 1: Personal Projects (Most Users)**
```
3-5 small apps
~50,000 requests/month each
~10-20 daily active users each
Result: $0.00/month ✅
```

**Scenario 2: One Popular App**
```
1 app with moderate traffic
~500,000 requests/month
~100 daily active users
Result: $0.00/month ✅
```

**Scenario 3: Mixed Usage**
```
1 main app: 800K requests/month
2 side projects: 200K requests/month each
3 demos: 50K requests/month each
Total: 1.35M requests/month
Result: $0.00/month ✅
```

---

## 🚨 Warning Signs You're Approaching Limits

### Check Monthly Usage
1. Go to: https://console.cloud.google.com/run
2. Click on each service
3. Look at **Metrics** tab
4. If you see:
   - Request count > 500K/month → Monitor closely
   - Billable time > 50K GB-seconds → Optimize or reduce max instances

### Set Up Alerts
Budget alerts already set up in `DEPLOY_GUIDE.md`:
- Alert at $2.50 (50% of $5 budget)
- Alert at $4.50 (90% of $5 budget)
- Alert at $5.00 (100%)

**Note:** Even $5/month is minimal, but you can stay at $0!

---

## 🎯 Optimization Checklist

Before deploying each project:

- [ ] `minInstances: 0` ✅
- [ ] `maxInstances: 10` or less ✅
- [ ] Memory: `512Mi` (only increase if needed) ✅
- [ ] CPU: `1` (only increase if needed) ✅
- [ ] CPU allocation: **"During requests only"** ✅
- [ ] Region: `us-central1` ✅
- [ ] Docker image optimized (Alpine Linux, multi-stage build) ✅

---

## 💡 Cost-Saving Tips

### 1. Optimize Docker Images
- Use Alpine Linux: `FROM node:18-alpine`
- Multi-stage builds (already in SpotAI Dockerfile)
- Smaller images = faster builds = lower costs

### 2. Efficient Code
- Close database connections promptly
- Clean up memory (delete unused objects)
- Avoid memory leaks

### 3. Smart Scaling
```javascript
// In your app, add graceful shutdown:
process.on('SIGTERM', () => {
  server.close(() => {
    console.log('Process terminated');
  });
});
```

### 4. Cache Static Assets
- Use CDN for images/videos (Cloudflare free tier)
- Serve static files efficiently with Express

### 5. Monitor Regularly
- Check usage weekly for first month
- Set calendar reminder
- Adjust max instances if needed

---

## 📈 When You Might Exceed Free Tier

### Traffic Estimates
```
To exceed 2M requests/month:
- Need 66,666 requests/day
- OR ~3,000 active users/day visiting 20 pages each
- This is a LOT for a side project!
```

### If You Do Exceed
Even if you hit 3M requests (50% over):
```
Overage: 1M requests × $0.40 = $0.40
Total monthly cost: $0.40

Still cheaper than any VPS! 🎉
```

---

## 🔍 Monthly Monitoring Routine

### Every Monday (5 minutes):
1. Open: https://console.cloud.google.com/run
2. Check each service:
   - Request count
   - Billable time
   - Error rate
3. If any service > 500K requests:
   - Check if it's expected growth
   - Consider optimizations
   - Maybe reduce max instances temporarily

### Every Month (10 minutes):
1. Check billing: https://console.cloud.google.com/billing
2. Verify: $0.00 (or minimal)
3. Review usage trends
4. Plan for next month

---

## 🎯 Real-World Examples

### My Setup (Example)
```
Project 1: SpotAI Game
- 50K requests/month
- 5-10 daily users
- Cost: $0.00

Project 2: Personal Blog
- 30K requests/month
- 100 monthly visitors
- Cost: $0.00

Project 3: Todo App
- 20K requests/month
- Personal use
- Cost: $0.00

Total: 100K requests/month
Free tier remaining: 1.9M requests ✅
```

---

## ✨ Summary

**To stay at $0/month:**
1. ✅ Min instances = 0
2. ✅ Max instances ≤ 10
3. ✅ Memory = 512Mi
4. ✅ CPU only during requests
5. ✅ Use us-central1 region
6. ✅ Monitor monthly

**Follow these rules and you'll never pay a cent!** 🎉

---

## Quick Commands

### Check Current Usage (UI)
1. https://console.cloud.google.com/run
2. Click service → Metrics tab

### Check Billing
1. https://console.cloud.google.com/billing
2. Reports → Filter: Cloud Run

### View Costs in Real-Time
1. https://console.cloud.google.com/billing
2. Should always show: $0.00 ✅

---

*Last updated: February 2026*
