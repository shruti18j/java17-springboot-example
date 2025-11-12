# GCP Setup
Project: java17-spring-boot-demo-47761
Region: asia-south1

gcloud auth login
gcloud config set project java17-spring-boot-demo-47761
gcloud config set run/region asia-south1
gcloud services enable run.googleapis.com artifactregistry.googleapis.com cloudbuild.googleapis.com iamcredentials.googleapis.com pubsub.googleapis.com

# Create Artifact Registry (once)
gcloud artifacts repositories create orgapp-repo --repository-format=docker --location=asia-south1 --description="Java17 microservices"

# Create Pub/Sub topic (once)
gcloud pubsub topics create orders-topic
