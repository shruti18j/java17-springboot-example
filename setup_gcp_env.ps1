param([string]$ProjectId="java17-spring-boot-demo-47761",[string]$Region="asia-south1")
Write-Host "Configuring $ProjectId in $Region"
gcloud config set project $ProjectId
gcloud config set run/region $Region
gcloud services enable run.googleapis.com artifactregistry.googleapis.com cloudbuild.googleapis.com iamcredentials.googleapis.com pubsub.googleapis.com
$repo="orgapp-repo"
$exists = gcloud artifacts repositories list --location=$Region --format="value(name)" | Select-String $repo
if (-not $exists) {
  gcloud artifacts repositories create $repo --repository-format=docker --location=$Region --description="Java17 services"
} else { Write-Host "Artifact Registry $repo exists" }
Write-Host "Done"
