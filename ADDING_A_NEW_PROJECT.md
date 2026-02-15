# Adding a New Project — Step-by-Step Guide

This guide walks you through adding any new project (regardless of language or framework) to the Cloud Deployment Hub so that it is automatically built and deployed to Google Cloud Run.

---

## Prerequisites

Before you begin, make sure:

- [ ] You have a GitHub repository for your project.
- [ ] The **one-time setup** of the `projects` repository is already done (GCP service account, `GCP_SA_KEY` secret). See the [main README](README.md) if not.

---

## Step 1 — Add a `Dockerfile` to Your Project

Your project **must** have a `Dockerfile` in its repository (typically at the root). This is the only hard requirement — the deployment system uses Docker to build any project, regardless of language or framework.

The Dockerfile should:

1. **Build** your application (install dependencies, compile, bundle, etc.).
2. **Expose a port** that matches what you'll configure later (default `8080`).
3. **Read the `PORT` environment variable** — Cloud Run sets this at runtime.

### Example (Node.js)

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --omit=dev
COPY . .
ENV PORT=8080
EXPOSE 8080
CMD ["node", "index.js"]
```

### Example (Python / Flask)

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
ENV PORT=8080
EXPOSE 8080
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"]
```

### Example (Go)

```dockerfile
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o server .

FROM alpine:3.18
WORKDIR /app
COPY --from=builder /app/server .
ENV PORT=8080
EXPOSE 8080
CMD ["./server"]
```

> **Key rule**: Your application must listen on `0.0.0.0` using the `PORT` environment variable, e.g.:
>
> ```
> server.listen(process.env.PORT || 8080, '0.0.0.0')   // Node.js
> app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 8080)))  # Python
> ```

---

## Step 2 — Register the Project in `deploy-config.json`

Open `deploy-config.json` in the `projects` repository and add a new entry to the `"projects"` array:

```json
{
  "name": "my-new-tool",
  "displayName": "My New Tool",
  "description": "Short description of what the tool does",
  "serviceName": "my-new-tool",
  "port": 8080,
  "repository": "https://github.com/GabrieleRomano98/my-new-tool.git",
  "dockerfile": "Dockerfile",
  "active": true
}
```

### Field Reference

| Field           | Required | Description                                                       |
| --------------- | -------- | ----------------------------------------------------------------- |
| `name`          | ✅        | Internal identifier (lowercase, no spaces). Used in deploy logs.  |
| `displayName`   | ❌        | Human-readable name.                                              |
| `description`   | ❌        | Short description.                                                |
| `serviceName`   | ✅        | Cloud Run service name (lowercase, hyphens allowed, max 63 chars).|
| `port`          | ✅        | The port your container listens on (usually `8080`).              |
| `repository`    | ✅        | Full HTTPS GitHub URL ending in `.git`.                           |
| `dockerfile`    | ❌        | Path to Dockerfile relative to repo root. Defaults to `Dockerfile`. |
| `active`        | ✅        | Set to `true` to enable deployment, `false` to disable.          |

---

## Step 3 — Set Up Automatic Deployment from Your Project Repository

This step makes it so that every `git push` to your project automatically triggers a deployment.

### 3.1 — Create a GitHub Personal Access Token (if you don't have one already)

1. Go to **GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)**.
2. Click **Generate new token (classic)**.
3. Give it a descriptive name (e.g. `deploy-trigger`).
4. Select scopes: **`repo`** and **`workflow`**.
5. Click **Generate token** and **copy** the value.

### 3.2 — Add the Token as a Secret in Your Project Repository

1. Go to your project repository on GitHub.
2. Navigate to **Settings → Secrets and variables → Actions**.
3. Click **New repository secret**.
4. Name: `DEPLOY_TOKEN`
5. Value: paste the personal access token from step 3.1.
6. Click **Add secret**.

### 3.3 — Add the Trigger Workflow File

Create the file `.github/workflows/trigger-deploy.yml` in your project repository with the following content:

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
      - name: Trigger deployment in projects repository
        run: |
          curl -X POST \
            -H "Accept: application/vnd.github.v3+json" \
            -H "Authorization: token ${{ secrets.DEPLOY_TOKEN }}" \
            https://api.github.com/repos/GabrieleRomano98/my-cloud-apps/dispatches \
            -d '{"event_type":"deploy-request","client_payload":{"project_name":"MY-PROJECT-NAME"}}'

      - name: Deployment triggered
        run: |
          echo "✅ Deployment triggered in projects repository"
          echo "Watch progress at: https://github.com/GabrieleRomano98/my-cloud-apps/actions"
```

> **⚠️ Important**: Replace `MY-PROJECT-NAME` with the exact `name` value you used in `deploy-config.json` (e.g., `my-new-tool`).

---

## Step 4 — Commit and Push

### 4.1 — Push the workflow file in your project repository

```bash
cd my-new-tool
git add .github/workflows/trigger-deploy.yml
git commit -m "Add auto-deploy trigger workflow"
git push
```

### 4.2 — Push the updated config in the `projects` repository

```bash
cd projects
git add deploy-config.json
git commit -m "Add my-new-tool to deployment config"
git push
```

> Pushing to the `projects` repository will immediately trigger a deployment of **all active projects**. This serves as the first deployment of your new project.

---

## Step 5 — Verify the Deployment

1. Go to the **GitHub Actions** tab of the `projects` repository.
2. You should see a workflow run in progress.
3. Once it completes (typically 5–10 minutes), your service is live.
4. Find your service URL in the [Google Cloud Run Console](https://console.cloud.google.com/run) → select your service → the URL is at the top.

---

## How It All Works (Summary)

```
You push code to your project repo
        ↓
trigger-deploy.yml fires (GitHub Actions)
        ↓
Sends a repository_dispatch event to the projects repo
        ↓
auto-deploy.yml in projects repo runs:
  1. Reads deploy-config.json
  2. Clones your project repository
  3. Builds Docker image from your Dockerfile
  4. Pushes image to Google Artifact Registry
  5. Deploys to Cloud Run
        ↓
Your app is live at https://[service]-[hash].run.app
```

---

## Quick Checklist

| #  | Task                                                               | Done? |
| -- | ------------------------------------------------------------------ | ----- |
| 1  | Project has a working `Dockerfile`                                 | ☐     |
| 2  | App listens on `0.0.0.0` and reads `PORT` env var                 | ☐     |
| 3  | Entry added to `deploy-config.json` with `active: true`           | ☐     |
| 4  | `DEPLOY_TOKEN` secret added to project repository                 | ☐     |
| 5  | `.github/workflows/trigger-deploy.yml` added to project repo      | ☐     |
| 6  | `client_payload.project_name` matches `name` in config            | ☐     |
| 7  | Changes pushed to both repositories                                | ☐     |
| 8  | Deployment verified in GitHub Actions & Cloud Run Console          | ☐     |

---

## Troubleshooting

| Problem                          | Solution                                                                 |
| -------------------------------- | ------------------------------------------------------------------------ |
| Workflow not triggering          | Check that `DEPLOY_TOKEN` secret is set and token has `repo` + `workflow` scopes. |
| Docker build fails               | Test locally with `docker build -t test .` before pushing.               |
| Service won't start              | Check Cloud Run logs. Ensure the app binds to `0.0.0.0:$PORT`.          |
| Wrong project deployed           | Verify `client_payload.project_name` matches `name` in `deploy-config.json`. |
| Deployment skipped               | Ensure `active` is set to `true` in `deploy-config.json`.               |

---

## Environment Variables on Cloud Run

If your project needs environment variables (API keys, secrets, etc.), you can set them directly in Cloud Run after the first deployment:

1. Go to [Cloud Run Console](https://console.cloud.google.com/run).
2. Select your service → **Edit & Deploy New Revision**.
3. Expand **Variables & Secrets** → add your variables.
4. Click **Deploy**.

These variables persist across future deployments.
