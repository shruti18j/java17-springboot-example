GCP Project: java17-spring-boot-demo-47761
Region: asia-south1
Enable required services:
gcloud services enable run.googleapis.com artifactregistry.googleapis.com cloudbuild.googleapis.com pubsub.googleapis.com
Create Artifact Registry:
gcloud artifacts repositories create java17-repo --repository-format=docker --location=asia-south1 || true
Create Pub/Sub topic:
gcloud pubsub topics create orders-topic || true
