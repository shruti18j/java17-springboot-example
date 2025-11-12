# Java17 Microservices
- org-app: GET /health
- file-upload-service: POST /upload, GET /files, GET /download/{name}
- orders-kafka-service:
  - POST /orders  (inmem/kafka/pubsub based on SPRING_PROFILES_ACTIVE)
  - GET /events
