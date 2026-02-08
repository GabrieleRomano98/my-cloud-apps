# Cloud Deployment Hub

Centralized deployment system for managing multiple applications on Google Cloud Run.

## Overview

This repository automates deployments through GitHub Actions. When you push to a configured project, it automatically builds and deploys to Cloud Run.

## Setup

### Prerequisites
- Google Cloud account
- GitHub account with repository access

### One-Time Configuration

**1. Create Google Cloud Service Account**

In Google Cloud Console (IAM & Admin → Service Accounts):
- Create service account
- Add roles: Cloud Run Admin, Cloud Build Editor, Artifact Registry Administrator, Service Account User
- Generate and download JSON key

**2. Add Secret to This Repository**

In GitHub repository settings → Secrets and variables → Actions:
- Name: `GCP_SA_KEY`
- Value: Contents of the downloaded JSON key file

**3. Configure Project List**

Edit `deploy-config.json`:
```json
{
  "googleCloud": {
    "projectId": "your-project-id",
    "region": "us-central1"
  },
  "projects": [
    {
      "name": "myapp",
      "repository": "https://github.com/user/myapp.git",
      "serviceName": "myapp",
      "port": 8080,
      "active": true
    }
  ]
}
```

**4. Set Up Project Repositories**

For each project that should auto-deploy:

a) Create GitHub Personal Access Token:
   - Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
   - Generate new token with `repo` and `workflow` scopes
   - Copy the token

b) Add to project repository secrets:
   - Name: `DEPLOY_TOKEN`
   - Value: Your token

c) Add `.github/workflows/trigger-deploy.yml` to the project:
```yaml
name: Deploy

on:
  push:
    branches: [master, main]

jobs:
  trigger:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger deployment
        run: |
          curl -X POST \
            -H "Authorization: token ${{ secrets.DEPLOY_TOKEN }}" \
            https://api.github.com/repos/YOUR-USERNAME/my-cloud-apps/dispatches \
            -d '{"event_type":"deploy-request","client_payload":{"project_name":"PROJECT-NAME"}}'
```

## Usage

### Automatic Deployment

Push to any configured project repository:
```bash
git push
```

Deployment happens automatically within 5-10 minutes.

### Deploy All Projects

Push to this repository:
```bash
cd my-cloud-apps
git push
```

### Manual Deployment

Use GitHub Actions tab → Run workflow manually

## How It Works

```
Your Project (git push)
  ↓
Webhook to my-cloud-apps
  ↓
GitHub Actions:
  - Clones project repository
  - Builds Docker image
  - Pushes to Google Artifact Registry
  - Deploys to Cloud Run
  ↓
Application live at https://[service]-[hash].run.app
```

## Configuration Options

### deploy-config.json Structure

```json
{
  "googleCloud": {
    "projectId": "string",
    "region": "string",
    "defaultConfig": {
      "cpu": 1,
      "memory": "512Mi",
      "minInstances": 0,
      "maxInstances": 1,
      "timeout": 300
    }
  },
  "projects": [
    {
      "name": "string",           // Internal identifier
      "displayName": "string",    // Optional display name
      "repository": "string",     // Full GitHub URL
      "serviceName": "string",    // Cloud Run service name
      "port": 8080,              // Container internal port
      "dockerfile": "Dockerfile", // Path to Dockerfile
      "active": true             // Enable/disable deployment
    }
  ]
}
```

### Resource Limits

Default settings keep you within free tier:
- CPU: 1 vCPU
- Memory: 512Mi
- Min instances: 0 (scales to zero when idle)
- Max instances: 1
- Timeout: 300 seconds

Adjust based on your needs, but monitor costs.

## Monitoring

### Deployment Status
- **Workflow runs**: GitHub Actions tab
- **Cloud Run services**: https://console.cloud.google.com/run
- **Logs**: Cloud Run → Select service → Logs tab

### Cost Tracking
- Google Cloud Console → Billing
- Set up budget alerts (recommended: $5/month)

### Free Tier Limits
- 2 million requests/month
- 360,000 GB-seconds of memory
- 180,000 vCPU-seconds

## Troubleshooting

### Build Failures
Check GitHub Actions logs. Common issues:
- Missing or invalid Dockerfile
- Application build errors
- Dependency installation failures

### Service Won't Start
Check Cloud Run logs for:
- Server not binding to 0.0.0.0
- PORT environment variable not being read
- Application crashes on startup

### Permission Errors
Verify:
- Service account has all required roles
- GCP_SA_KEY secret contains valid JSON
- GitHub token has repo and workflow scopes

## Project Requirements

Each deployed project needs:

1. **Dockerfile** in repository root
2. **Server configuration**:
   ```javascript
   const PORT = process.env.PORT || 8080;
   server.listen(PORT, '0.0.0.0');
   ```
3. **Health check**: Server responds on configured port

## Adding New Projects

1. Ensure project has valid Dockerfile
2. Add entry to `deploy-config.json`
3. Add trigger workflow to project repository
4. Push changes
5. Project deploys automatically

## Security Notes

- Service account keys stored as encrypted GitHub secrets
- Secrets never visible in logs or code
- Use minimal IAM roles required for deployment
- Rotate service account keys periodically
- Review GitHub token permissions regularly

## License

MIT
