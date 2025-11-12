# Minimal helper to guide GCP setup
Write-Host "Setting GCP project to java17-spring-boot-demo-47761"
gcloud config set project java17-spring-boot-demo-47761
gcloud services enable run.googleapis.com artifactregistry.googleapis.com cloudbuild.googleapis.com pubsub.googleapis.com
gcloud artifacts repositories create java17-repo --repository-format=docker --location=asia-south1 --description="Java17 images" || Write-Host "Repo exists"
gcloud pubsub topics create orders-topic || Write-Host "Topic exists"
Write-Host "GCP helper done."
