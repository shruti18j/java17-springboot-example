# ==============================================================
# setup_gcp_env.ps1
# Automated GCP Environment Setup for Java17 Spring Boot Demo
# Author: Shruti Sinha | 2025
# ==============================================================

$ProjectId = "java17-spring-boot-demo-47761"
$ProjectNumber = "312643665571"
$ProjectName = "Java17 Spring Boot Demo"
$Region = "asia-south1"
$ArtifactRepo = "orgapp-repo"
$ServiceAccount = "github-deployer@$ProjectId.iam.gserviceaccount.com"
$GitHubRepo = "shruti18j/java17-springboot-example"

Write-Host ""
Write-Host "Setting up Google Cloud Environment for $ProjectName..." -ForegroundColor Cyan

# Step 1: Configure Project & Region
Write-Host "`n[1/7] Setting GCP configuration..." -ForegroundColor Yellow
gcloud config set project $ProjectId
gcloud config set run/region $Region

# Step 2: Enable Required APIs
Write-Host "`n[2/7] Enabling necessary Google Cloud APIs..." -ForegroundColor Yellow
gcloud services enable run.googleapis.com artifactregistry.googleapis.com cloudbuild.googleapis.com iamcredentials.googleapis.com

# Step 3: Create Artifact Registry
Write-Host "`n[3/7] Checking or creating Artifact Registry ($ArtifactRepo)..." -ForegroundColor Yellow
$repoExists = gcloud artifacts repositories list --location=$Region --format="value(name)" | Select-String $ArtifactRepo
if (-not $repoExists) {
    gcloud artifacts repositories create $ArtifactRepo `
        --repository-format=docker `
        --location=$Region `
        --description="Docker repo for Java17 Spring Boot Demo microservices"
} else {
    Write-Host "Artifact Registry already exists: $ArtifactRepo" -ForegroundColor Green
}

# Step 4: Create GitHub Deployer Service Account
Write-Host "`n[4/7] Checking or creating service account ($ServiceAccount)..." -ForegroundColor Yellow
$saExists = gcloud iam service-accounts list --format="value(email)" | Select-String $ServiceAccount
if (-not $saExists) {
    gcloud iam service-accounts create "github-deployer" `
        --display-name="GitHub Cloud Run Deployer"
} else {
    Write-Host "Service account already exists." -ForegroundColor Green
}

# Step 5: Assign IAM Roles
Write-Host "`n[5/7] Assigning IAM roles to service account..." -ForegroundColor Yellow
$roles = @(
    "roles/run.admin",
    "roles/storage.admin",
    "roles/artifactregistry.admin"
)
foreach ($role in $roles) {
    gcloud projects add-iam-policy-binding $ProjectId `
        --member="serviceAccount:$ServiceAccount" `
        --role=$role | Out-Null
    Write-Host "Granted $role" -ForegroundColor Green
}

# Step 6: Configure Workload Identity Federation (OIDC)
Write-Host "`n[6/7] Configuring Workload Identity Federation (OIDC)..." -ForegroundColor Yellow
$poolName = "github-pool"
$providerName = "github-provider"

# Create pool if not exists
$poolExists = gcloud iam workload-identity-pools list --location="global" --format="value(name)" | Select-String $poolName
if (-not $poolExists) {
    gcloud iam workload-identity-pools create $poolName `
        --location="global" `
        --display-name="GitHub Actions Pool"
} else {
    Write-Host "Workload Identity Pool exists." -ForegroundColor Green
}

# Create provider if not exists
$providerExists = gcloud iam workload-identity-pools providers list --workload-identity-pool=$poolName --location="global" --format="value(name)" | Select-String $providerName
if (-not $providerExists) {
    gcloud iam workload-identity-pools providers create-oidc $providerName `
        --workload-identity-pool=$poolName `
        --location="global" `
        --display-name="GitHub OIDC Provider" `
        --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository" `
        --issuer-uri="https://token.actions.githubusercontent.com"
} else {
    Write-Host "OIDC Provider exists." -ForegroundColor Green
}

# Bind the service account to the pool
Write-Host "`nLinking GitHub repo to OIDC pool..." -ForegroundColor Yellow
gcloud iam service-accounts add-iam-policy-binding $ServiceAccount `
    --role="roles/iam.workloadIdentityUser" `
    --member="principalSet://iam.googleapis.com/projects/$ProjectNumber/locations/global/workloadIdentityPools/$poolName/attribute.repository/$GitHubRepo"

# Step 7: Print Summary
Write-Host "`n------------------------------------------------------"
Write-Host "Setup Completed Successfully!"
Write-Host "Project ID:      $ProjectId"
Write-Host "Project Number:  $ProjectNumber"
Write-Host "Region:          $Region"
Write-Host "Artifact Repo:   $ArtifactRepo"
Write-Host "Service Account: $ServiceAccount"
Write-Host "------------------------------------------------------" -ForegroundColor Green
Write-Host "`nYou are ready to deploy via GitHub Actions or Cloud Build." -ForegroundColor Cyan
