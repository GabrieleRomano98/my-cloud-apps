#!/bin/bash
# =============================================================================
# VM Initial Setup Script
# Run this ONCE on a fresh e2-micro VM to install Docker, Nginx, and configure
# the environment for automated deployments.
#
# Usage: ssh into the VM and run:
#   curl -sSL https://raw.githubusercontent.com/GabrieleRomano98/my-cloud-apps/master/vm-setup/init.sh | bash
#   OR copy this file to the VM and run: bash init.sh
# =============================================================================

set -e

echo "========================================="
echo "  VM Initial Setup"
echo "========================================="

# Update system (skip upgrade to avoid slow gcloud update on e2-micro)
echo "📦 Updating package list..."
sudo apt-get update -y

# Install Docker
echo "🐳 Installing Docker..."
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add current user to docker group (so we don't need sudo)
sudo usermod -aG docker $USER

# Install Nginx
echo "🌐 Installing Nginx..."
sudo apt-get install -y nginx

# Create app directories
echo "📁 Creating directory structure..."
sudo mkdir -p /opt/apps
sudo mkdir -p /opt/apps/nginx
sudo chown -R $USER:$USER /opt/apps

# Create the deploy script
echo "📝 Creating deploy script..."
cat > /opt/apps/deploy.sh << 'DEPLOY_SCRIPT'
#!/bin/bash
# =============================================================================
# Deploy Script — called by GitHub Actions via SSH
# Usage: bash /opt/apps/deploy.sh <project-name> <repo-url> <port> <dockerfile>
# =============================================================================

set -e

PROJECT_NAME=$1
REPO_URL=$2
PORT=$3
DOCKERFILE=${4:-Dockerfile}

if [ -z "$PROJECT_NAME" ] || [ -z "$REPO_URL" ] || [ -z "$PORT" ]; then
  echo "❌ Usage: deploy.sh <project-name> <repo-url> <port> [dockerfile]"
  exit 1
fi

APP_DIR="/opt/apps/$PROJECT_NAME"

echo "========================================="
echo "  Deploying: $PROJECT_NAME"
echo "  Port: $PORT"
echo "========================================="

# Clone or pull the repository
if [ -d "$APP_DIR" ]; then
  echo "📥 Pulling latest changes..."
  cd "$APP_DIR"
  git fetch origin
  git reset --hard origin/$(git rev-parse --abbrev-ref HEAD)
else
  echo "📥 Cloning repository..."
  git clone "$REPO_URL" "$APP_DIR"
  cd "$APP_DIR"
fi

# Load environment variables if .env file exists
ENV_FILE="/opt/apps/$PROJECT_NAME.env"
ENV_ARGS=""
if [ -f "$ENV_FILE" ]; then
  echo "🔑 Loading environment variables from $ENV_FILE"
  while IFS= read -r line; do
    # Skip empty lines and comments
    if [ -n "$line" ] && [[ ! "$line" =~ ^# ]]; then
      ENV_ARGS="$ENV_ARGS -e $line"
    fi
  done < "$ENV_FILE"
fi

# Build Docker image
echo "🔨 Building Docker image..."
docker build -t "$PROJECT_NAME" -f "$DOCKERFILE" .

# Stop and remove existing container (if any)
echo "🛑 Stopping existing container..."
docker stop "$PROJECT_NAME" 2>/dev/null || true
docker rm "$PROJECT_NAME" 2>/dev/null || true

# Run new container
echo "🚀 Starting new container..."
docker run -d \
  --name "$PROJECT_NAME" \
  --restart unless-stopped \
  -p "127.0.0.1:$PORT:$PORT" \
  -e "PORT=$PORT" \
  -e "NODE_ENV=production" \
  $ENV_ARGS \
  "$PROJECT_NAME"

# Cleanup old Docker images
echo "🧹 Cleaning up old images..."
docker image prune -f

echo "✅ $PROJECT_NAME deployed successfully on port $PORT!"
DEPLOY_SCRIPT

chmod +x /opt/apps/deploy.sh

# Create Nginx config
echo "🌐 Configuring Nginx..."
sudo tee /etc/nginx/sites-available/apps > /dev/null << 'NGINX_CONF'
# Redirect HTTP to HTTPS (uncomment when SSL is configured)
# server {
#     listen 80;
#     server_name _;
#     return 301 https://$host$request_uri;
# }

server {
    listen 80;
    server_name _;

    # SpotAI
    location /spotai/ {
        proxy_pass http://127.0.0.1:3001/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 86400s;  # SSE connections need long timeout
        proxy_buffering off;        # Required for SSE
    }

    # Pokemon Guess
    location /pokemon-guess/ {
        proxy_pass http://127.0.0.1:3002/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Default: show a simple status page
    location / {
        default_type text/html;
        return 200 '<html><body><h1>App Server</h1><ul><li><a href="/spotai/">SpotAI</a></li><li><a href="/pokemon-guess/">Pokemon Guess</a></li></ul></body></html>';
    }
}
NGINX_CONF

# Enable the site
sudo ln -sf /etc/nginx/sites-available/apps /etc/nginx/sites-enabled/apps
sudo rm -f /etc/nginx/sites-enabled/default

# Test and reload Nginx
sudo nginx -t
sudo systemctl reload nginx
sudo systemctl enable nginx

echo ""
echo "========================================="
echo "  ✅ VM Setup Complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "  1. Create .env files for each project:"
echo "     /opt/apps/spotai.env"
echo "     /opt/apps/pokemon-guess.env"
echo ""
echo "  2. Add your SSH key to GitHub Actions secrets"
echo ""
echo "  3. Push to your projects repo to trigger deployment"
echo ""
