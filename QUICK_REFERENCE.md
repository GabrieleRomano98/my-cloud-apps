# 🚀 Quick Reference Card

## Setup (One-Time)

```powershell
# 1. Clone this repository
git clone YOUR_PROJECTS_REPO_URL
cd projects

# 2. Run setup to clone all projects
.\setup.ps1

# 3. Update deploy-config.json with your GCP Project ID
# Edit: googleCloud.projectId = "YOUR-GCP-PROJECT-ID"
```

## Deploy a Project (UI Method)

1. **Open**: https://console.cloud.google.com/run
2. **Click**: Create Service
3. **Select**: Continuously deploy from repository
4. **Connect**: Your GitHub repository
5. **Configure**: 
   - Service name: `spotai`
   - Region: `us-central1`
   - CPU: 1, Memory: 512Mi
   - Min instances: 0, Max: 1 (⚠️ Important for Socket.IO!)
6. **Deploy**: Click Create
7. **Done**: Get your URL in 3-5 minutes!

**⚠️ Socket.IO Note:** Max instances should be `1` for SpotAI since Socket.IO keeps state in memory. Multiple instances mean users won't see each other's rooms unless you use Redis (advanced).

**Full guide**: [DEPLOY_GUIDE.md](./DEPLOY_GUIDE.md)

## Add a New Project

```powershell
# 1. Clone new project
cd projects
git clone YOUR_NEW_REPO project-name

# 2. Add to deploy-config.json
{
  "name": "project-name",
  "displayName": "My New Project",
  "path": "projects/project-name",
  "serviceName": "project-name",
  "repository": "YOUR_NEW_REPO_URL"
}

# 3. Ensure it has a Dockerfile

# 4. Deploy via UI (same as above)
```

## Update a Project

```powershell
# 1. Make changes locally
cd projects/project-name
# ... edit files ...

# 2. Commit and push
git add .
git commit -m "Update feature"
git push

# 3. Auto-deploys if using GitHub integration
# Otherwise: Edit & Deploy New Revision in Cloud Run UI
```

## Monitor

- **Services**: https://console.cloud.google.com/run
- **Billing**: https://console.cloud.google.com/billing
- **Logs**: Click service → Logs tab

## Free Tier Limits

| Resource | Limit |
|----------|-------|
| Requests | 2M/month |
| Memory | 360K GB-sec/month |
| CPU | 180K vCPU-sec/month |

**Tip**: With min-instances=0, you'll stay at $0!

## Configuration Checklist

Each project needs:
- ✅ Dockerfile
- ✅ Port 8080 (or configurable via PORT env var)
- ✅ Production build process
- ✅ Entry in deploy-config.json

## Key URLs

- **Cloud Run**: https://console.cloud.google.com/run
- **Cloud Build**: https://console.cloud.google.com/cloud-build
- **Billing**: https://console.cloud.google.com/billing
- **GitHub**: https://github.com/settings/installations

## Troubleshooting

**Build failed?**
- Check Dockerfile exists
- Verify Dockerfile syntax
- Check logs in Cloud Build

**503 errors?**
- Ensure PORT=8080
- Check app starts correctly
- Review service logs

**Costs increasing?**
- Verify min-instances=0
- Check max-instances ≤10
- Review metrics per service

## Quick Commands (Optional)

If you have gcloud CLI installed:

```powershell
# List services
gcloud run services list

# View logs
gcloud logging read "resource.type=cloud_run_revision"

# Update service
gcloud run services update spotai --region us-central1
```

But **UI is recommended** for simplicity!

---

📖 **Full Documentation**: See [README.md](./README.md) and [DEPLOY_GUIDE.md](./DEPLOY_GUIDE.md)
