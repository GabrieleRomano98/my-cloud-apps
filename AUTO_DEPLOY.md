# 🚀 Automatic Deployment Setup

This repository is configured for **automatic deployment** to Google Cloud Run. When you push changes, GitHub Actions automatically deploys your projects.

---

## How It Works

```
1. You push to my-cloud-apps repository
   ↓
2. GitHub Actions reads deploy-config.json
   ↓
3. For each active project:
   - Clones the project repository
   - Builds Docker image
   - Pushes to Artifact Registry
   - Deploys to Cloud Run
   ↓
4. Your apps are live! ✅
```

---

## Initial Setup (One-Time)

### 1. Create Google Cloud Service Account

This allows GitHub Actions to deploy to your Cloud Run.

**Via Google Cloud Console:**

1. Go to: https://console.cloud.google.com/iam-admin/serviceaccounts
2. Click **Create Service Account**
3. Enter:
   - **Name:** `github-actions-deployer`
   - **Description:** `Service account for GitHub Actions to deploy to Cloud Run`
4. Click **Create and Continue**
5. Add these roles:
   - **Cloud Run Admin**
   - **Cloud Build Editor**
   - **Artifact Registry Administrator**
   - **Service Account User**
6. Click **Continue** → **Done**

### 2. Create Service Account Key

1. Click on the service account you just created
2. Go to **Keys** tab
3. Click **Add Key** → **Create New Key**
4. Choose **JSON** format
5. Click **Create**
6. A JSON file downloads - **keep this safe!**

### 3. Add Secret to GitHub

1. Go to your GitHub repository: https://github.com/GabrieleRomano98/my-cloud-apps
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Enter:
   - **Name:** `GCP_SA_KEY`
   - **Value:** Paste the entire contents of the JSON file you downloaded
5. Click **Add secret**

### 4. Update deploy-config.json

Replace `YOUR-GCP-PROJECT-ID` with your actual Google Cloud Project ID:

```json
{
  "googleCloud": {
    "projectId": "my-actual-project-id",  // ← Change this!
    "region": "us-central1",
    ...
  }
}
```

### 5. Enable Required APIs

Via Google Cloud Console:
1. Go to: https://console.cloud.google.com/apis/library
2. Search and enable:
   - **Cloud Run Admin API**
   - **Cloud Build API**
   - **Artifact Registry API**

---

## Usage

### Adding a New Project

**1. Add to deploy-config.json:**
```json
{
  "projects": [
    {
      "name": "spotai",
      "displayName": "SpotAI Game",
      "repository": "https://github.com/GabrieleRomano98/SpotAI.git",
      "serviceName": "spotai",
      "port": 8080,
      "active": true
    },
    // 👇 Add your new project
    {
      "name": "myapp",
      "displayName": "My New App",
      "repository": "https://github.com/GabrieleRomano98/MyNewApp.git",
      "serviceName": "myapp",
      "port": 3000,
      "dockerfile": "Dockerfile",
      "active": true
    }
  ]
}
```

**2. Commit and push:**
```powershell
git add deploy-config.json
git commit -m "Add MyNewApp to deployment"
git push
```

**3. Watch it deploy automatically!**
- Go to: https://github.com/GabrieleRomano98/my-cloud-apps/actions
- See the deployment progress in real-time
- Takes 5-10 minutes per project

**4. Check Cloud Run:**
- Go to: https://console.cloud.google.com/run
- Your new service is live!

---

## Deployment Triggers

Auto-deployment runs when:

✅ **You push to master/main branch**
```powershell
git push origin master
```

✅ **You modify deploy-config.json** (adds/updates projects)
```json
// Change any project configuration
// All active projects redeploy
```

✅ **Manual trigger via GitHub**
- Go to: https://github.com/GabrieleRomano98/my-cloud-apps/actions
- Click **Auto Deploy to Cloud Run**
- Click **Run workflow**

---

## Project Requirements

Each project repository must have:

**Required:**
- ✅ `Dockerfile` - Defines how to build the container
- ✅ Valid port configuration (default: 8080)
- ✅ Must listen on `0.0.0.0` not `localhost`

**Example Dockerfile:**
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 8080
CMD ["node", "server.js"]
```

**Example server.js:**
```javascript
const PORT = process.env.PORT || 8080;
app.listen(PORT, '0.0.0.0', () => {  // ← Must bind to 0.0.0.0
  console.log(`Server running on port ${PORT}`);
});
```

---

## Monitoring Deployments

### Via GitHub Actions
1. Go to: https://github.com/GabrieleRomano98/my-cloud-apps/actions
2. Click on latest workflow run
3. See detailed logs for each step

### Via Google Cloud Console
1. Go to: https://console.cloud.google.com/run
2. Click on your service
3. Check **Revisions** tab for deployment history
4. Check **Logs** tab for runtime logs

---

## Deployment Status

After pushing, check deployment status:

**✅ Success:**
```
✅ spotai deployed successfully!
✅ myapp deployed successfully!
🎉 All projects deployed successfully!
```

**❌ Failed:**
- Check GitHub Actions logs for errors
- Common issues:
  - Missing Dockerfile
  - Wrong port configuration
  - Build errors in project code
  - Service account permissions

---

## Disabling Auto-Deployment for a Project

Set `"active": false` in deploy-config.json:

```json
{
  "name": "old-app",
  "active": false  // ← Won't deploy
}
```

---

## Cost Management

All deployments share the same free tier:
- **2M requests/month** across all services
- **360,000 GB-seconds** of memory
- **180,000 vCPU-seconds**

**Monitor usage:**
1. Go to: https://console.cloud.google.com/billing
2. Check **Reports** for current usage
3. Set up budget alerts (recommended: $5/month)

---

## Rollback a Deployment

If something goes wrong:

**Via Google Cloud Console:**
1. Go to: https://console.cloud.google.com/run
2. Click on the service
3. Click **Revisions** tab
4. Find the previous working revision
5. Click **⋮** → **Manage Traffic**
6. Route 100% traffic to previous revision
7. Click **Save**

**Via GitHub:**
1. Revert your commit
2. Push again - auto-deploys previous version

---

## Manual Deployment

If you need to deploy without GitHub Actions:

**Via UI (follow DEPLOY_GUIDE.md):**
- Standard Cloud Run deployment process
- Use when testing or troubleshooting

**Via gcloud CLI:**
```powershell
# Not recommended - defeats the purpose of this repo
# But available if needed
gcloud run deploy SERVICE_NAME --source .
```

---

## Troubleshooting

### Deployment fails with "Permission denied"
- Check service account has all required roles
- Verify GCP_SA_KEY secret is correct

### "Repository not found" error
- Check repository URL is correct and public
- For private repos, add GitHub token to workflow

### Build fails
- Check Dockerfile exists in project
- Test Docker build locally first
- Check logs in GitHub Actions

### Service won't start
- Verify port configuration (must match Dockerfile EXPOSE)
- Check server binds to `0.0.0.0` not `localhost`
- Review Cloud Run logs for startup errors

---

## Next Steps

1. ✅ Complete one-time setup above
2. ✅ Test with SpotAI deployment
3. ✅ Add your next project to deploy-config.json
4. ✅ Push and watch it auto-deploy!

---

**Questions?** Check [FAQ.md](./FAQ.md) or [DEPLOY_GUIDE.md](./DEPLOY_GUIDE.md)

*Last updated: February 2026*
