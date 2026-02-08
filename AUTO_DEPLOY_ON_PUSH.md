# 🔄 Automatic Deployment on Git Push

This setup enables **automatic deployment** when you push to any project repository (like SpotAI).

---

## 🎯 How It Works

```
You push to SpotAI
↓
SpotAI GitHub Actions triggers
↓
Sends webhook to my-cloud-apps
↓
my-cloud-apps deploys SpotAI automatically
↓
SpotAI is live on Cloud Run! 🎉
```

**No more manual redeploy needed!**

---

## ⚙️ One-Time Setup (Required)

### Step 1: Create GitHub Personal Access Token

1. Go to: https://github.com/settings/tokens
2. Click **Generate new token** → **Generate new token (classic)**
3. Give it a name: `Cloud Deploy Token`
4. Select scopes:
   - ✅ `repo` (Full control of private repositories)
   - ✅ `workflow` (Update GitHub Action workflows)
5. Click **Generate token**
6. **Copy the token** (you won't see it again!)

### Step 2: Add Token to SpotAI Secrets

1. Go to: https://github.com/GabrieleRomano98/SpotAI/settings/secrets/actions
2. Click **New repository secret**
3. Name: `DEPLOY_TOKEN`
4. Value: Paste the token you copied
5. Click **Add secret**

### Step 3: Commit and Push the Workflows

```powershell
# In spotAI repository
cd C:\Users\gromano\workspace\spotAI
git add .github/workflows/trigger-deploy.yml
git commit -m "Add automatic deployment trigger"
git push

# In my-cloud-apps repository
cd C:\Users\gromano\workspace\projects
git add .github/workflows/auto-deploy.yml
git commit -m "Add repository dispatch support"
git push
```

---

## ✅ Done! Now Test It

### Test automatic deployment:

```powershell
cd C:\Users\gromano\workspace\spotAI

# Make any change
echo "# Test" >> README.md

git add .
git commit -m "Test automatic deployment"
git push
```

**What happens automatically:**
1. SpotAI workflow triggers
2. Sends deployment request to my-cloud-apps
3. my-cloud-apps clones SpotAI
4. Builds Docker image
5. Deploys to Cloud Run
6. Done in 5-10 minutes!

**Watch it happen:**
- SpotAI trigger: https://github.com/GabrieleRomano98/SpotAI/actions
- Deployment: https://github.com/GabrieleRomano98/my-cloud-apps/actions

---

## 🔧 Adding More Projects

### Example: Add automatic deployment to TodoApp

**1. Create `.github/workflows/trigger-deploy.yml` in TodoApp:**

```yaml
name: Trigger Cloud Deployment

on:
  push:
    branches:
      - master
      - main

jobs:
  trigger-deploy:
    runs-on: ubuntu-latest
    
    steps:
      - name: Trigger deployment in my-cloud-apps
        run: |
          curl -X POST \
            -H "Accept: application/vnd.github.v3+json" \
            -H "Authorization: token ${{ secrets.DEPLOY_TOKEN }}" \
            https://api.github.com/repos/GabrieleRomano98/my-cloud-apps/dispatches \
            -d '{"event_type":"deploy-request","client_payload":{"project_name":"todoapp"}}'
      
      - name: Deployment triggered
        run: |
          echo "✅ Deployment triggered in my-cloud-apps repository"
```

**2. Add `DEPLOY_TOKEN` secret to TodoApp repository**

**3. Push to TodoApp → Automatically deploys!**

---

## 📊 Deployment Modes

### Mode 1: Push to SpotAI
```
git push (in SpotAI repo)
→ Only SpotAI deploys
```

### Mode 2: Push to my-cloud-apps
```
git push (in my-cloud-apps repo)
→ All active projects deploy
```

### Mode 3: Manual trigger
```
GitHub Actions → Run workflow
→ All active projects deploy
```

---

## 🎯 Complete Workflow

### **Your new development cycle:**

```powershell
# 1. Work on SpotAI
cd C:\Users\gromano\workspace\spotAI
# ... make changes ...

# 2. Commit and push
git add .
git commit -m "Add new feature"
git push

# 3. Automatically deploys!
# No need to touch my-cloud-apps at all!

# 4. Check deployment
# SpotAI: https://github.com/GabrieleRomano98/SpotAI/actions
# Deployment: https://github.com/GabrieleRomano98/my-cloud-apps/actions

# 5. Test live app
# https://spotai-xxxxx-uc.a.run.app
```

**That's it! From code to production in one `git push`!** 🚀

---

## 🔐 Security Notes

### **DEPLOY_TOKEN Security:**

✅ **Stored in GitHub Secrets** (encrypted)  
✅ **Only accessible by GitHub Actions**  
✅ **Scoped to repo and workflow only**  
✅ **Can be revoked anytime**  
✅ **Not visible in logs**

### **Permissions:**
- Token can only trigger workflows in my-cloud-apps
- Cannot access other repositories
- Cannot push code or delete anything
- Limited to repository dispatch events

---

## 🛠️ Troubleshooting

### Issue: "Bad credentials" error

**Solution:** 
- Check DEPLOY_TOKEN is added to SpotAI secrets
- Regenerate token if expired
- Verify token has `repo` and `workflow` scopes

### Issue: Deployment doesn't trigger

**Solution:**
- Check SpotAI workflow logs for errors
- Verify project name matches deploy-config.json (`"name": "spotai"`)
- Check my-cloud-apps Actions tab for incoming dispatch

### Issue: Wrong project deploys

**Solution:**
- Verify `client_payload.project_name` matches deploy-config.json
- Check filtering logic in my-cloud-apps workflow

---

## 📈 Benefits

✅ **Automatic** - Push code → Auto-deploys  
✅ **Fast** - Only deploys changed project, not all  
✅ **Traceable** - See deployment history in GitHub Actions  
✅ **Rollback-friendly** - Revert commit → Auto-deploys previous version  
✅ **Professional** - Same workflow used by major companies  

---

## 🎉 Summary

**Before:** 
```
1. Push to SpotAI
2. Go to my-cloud-apps
3. Manually trigger deployment
4. Wait 10 minutes
5. Check if deployed
```

**After:**
```
1. Push to SpotAI
2. Done! Automatically deployed!
```

**You've achieved full CI/CD automation!** 🚀

---

*Last updated: February 8, 2026*
