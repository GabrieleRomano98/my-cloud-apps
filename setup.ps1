# Setup Script for Multi-Project Repository
# This script helps you clone and set up projects for deployment

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Multi-Project Cloud Deployment Setup" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Check if projects directory exists
if (!(Test-Path "projects")) {
    Write-Host "Creating projects directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path "projects" | Out-Null
}

# Load configuration
if (!(Test-Path "deploy-config.json")) {
    Write-Host "Error: deploy-config.json not found!" -ForegroundColor Red
    exit 1
}

$config = Get-Content "deploy-config.json" | ConvertFrom-Json

Write-Host "Found $($config.projects.Length) project(s) in configuration:" -ForegroundColor Green
Write-Host ""

foreach ($project in $config.projects) {
    Write-Host "📦 $($project.displayName) ($($project.name))" -ForegroundColor Cyan
    Write-Host "   Path: $($project.path)" -ForegroundColor Gray
    Write-Host "   Repo: $($project.repository)" -ForegroundColor Gray
    
    $projectPath = $project.path
    
    if (Test-Path $projectPath) {
        Write-Host "   ✅ Already exists - pulling latest changes..." -ForegroundColor Green
        Push-Location $projectPath
        git pull
        Pop-Location
    }
    else {
        Write-Host "   📥 Cloning repository..." -ForegroundColor Yellow
        $parentDir = Split-Path $projectPath -Parent
        $dirName = Split-Path $projectPath -Leaf
        
        if (!(Test-Path $parentDir)) {
            New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
        }
        
        Push-Location $parentDir
        git clone $project.repository $dirName
        Pop-Location
        
        if (Test-Path $projectPath) {
            Write-Host "   ✅ Cloned successfully!" -ForegroundColor Green
        }
        else {
            Write-Host "   ❌ Clone failed!" -ForegroundColor Red
        }
    }
    
    Write-Host ""
}

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Setup Complete!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Review deploy-config.json and update YOUR-GCP-PROJECT-ID" -ForegroundColor White
Write-Host "2. Read DEPLOY_GUIDE.md for deployment instructions" -ForegroundColor White
Write-Host "3. Deploy via Google Cloud Console UI" -ForegroundColor White
Write-Host ""
Write-Host "Projects location: .\projects\" -ForegroundColor Cyan
Write-Host ""
