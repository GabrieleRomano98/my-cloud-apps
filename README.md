# My Cloud Projects - Multi-App Deployment Repository

This repository manages multiple projects deployed to Google Cloud Run, staying within the free tier.

---

## 🚀 Quick Start

### Current Projects
- **SpotAI** - Turn-based Q&A game with AI participant
  - Status: ✅ Active
  - URL: (will be set after deployment)

---

## 📁 Repository Structure

```
my-cloud-projects/
├── projects/                    # All your applications
│   ├── spotai/                 # SpotAI game
│   ├── project2/               # Future project
│   └── project3/               # Future project
├── deploy-config.json          # Deployment configuration
├── README.md                   # This file
└── DEPLOY_GUIDE.md            # Deployment instructions
```

---

## 🎯 How to Add a New Project

### 1. Clone Your New Project
```bash
cd projects
git clone YOUR_REPO_URL project-name
```

### 2. Add Project Configuration
Edit `deploy-config.json`:
```json
{
  "projects": [
    {
      "name": "spotai",
      "path": "projects/spotai",
      "serviceName": "spotai",
      "port": 8080
    },
    {
      "name": "your-new-project",
      "path": "projects/your-new-project",
      "serviceName": "your-new-project",
      "port": 8080
    }
  ]
}
```

### 3. Deploy via Google Cloud Console UI
See [DEPLOY_GUIDE.md](./DEPLOY_GUIDE.md) for step-by-step instructions.

---

## 💰 Free Tier Management

### Shared Resources Across All Projects
- **2M requests/month** total
- **360,000 GB-seconds memory/month** total  
- **180,000 vCPU-seconds/month** total

### Strategy
- Each project scales to zero when idle
- Estimated capacity: 3-5 small apps comfortably within free tier
- Monitor usage: https://console.cloud.google.com/run

---

## 📊 Current Usage

| Project | Status | Requests/Month | Notes |
|---------|--------|----------------|-------|
| SpotAI  | Active | ~50K | Well within limits ✅ |
| -       | -      | -    | - |
| -       | -      | -    | - |

---

## 🛠️ Maintenance

### Update a Project
```bash
cd projects/project-name
git pull
# Then redeploy via UI (see DEPLOY_GUIDE.md)
```

### Add New Project
```bash
cd projects
git clone YOUR_NEW_REPO new-project
# Add to deploy-config.json
# Deploy via UI
```

---

## 📖 Documentation

- **[DEPLOY_GUIDE.md](./DEPLOY_GUIDE.md)** - How to deploy via Google Cloud Console UI
- **[FREE_TIER_TIPS.md](./FREE_TIER_TIPS.md)** - Stay within free tier limits
- Each project has its own README in `projects/project-name/`

---

## 🎯 Goals

✅ One repository for all projects  
✅ Easy to add new projects  
✅ Deploy via UI (no CLI needed)  
✅ Stay within free tier  
✅ Simple maintenance  

---

**Last Updated:** February 2026
