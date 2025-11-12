# Java17 Spring Boot Microservices — Cloud Run (Kafka + Pub/Sub Ready)

Services:
- org-app — /health
- file-upload-service — /upload, /files, /download/{name}
- orders-kafka-service — /orders (publish), /events (consume)
  - Profiles:
    - inmem (default) — in-memory
    - kafka — Spring Kafka (KAFKA_BOOTSTRAP_SERVERS)
    - pubsub — Google Cloud Pub/Sub (GCP_PROJECT_ID, PUBSUB_TOPIC)

CI/CD:
- .github/workflows/build.yml — builds on push/PR (matrix per service)
- .github/workflows/deploy.yml — deploys changed services to Cloud Run on main
- .github/workflows/pages.yml — publishes /docs to GitHub Pages
