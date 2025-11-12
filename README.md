# Java17-Springboot-example — Multi-phase CI/CD Showcase (v5)
This repo demonstrates Java 17 + Spring Boot microservices with staged uploads (feature branches & PRs),
GitHub Actions CI, and deploy to Google Cloud Run (Artifact Registry).

GCP Project ID: `java17-spring-boot-demo-47761`
Region: `asia-south1`

Run:
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
$env:GH_TOKEN = "ghp_your_token_here"
.\scripts\init_upload.ps1
```
