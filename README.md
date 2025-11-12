# Java17-Springboot-example — Multi-phase CI/CD Showcase (Full)
This repo contains three microservices (OrgApp, File Upload, Orders) with full working code (Java 17, Spring Boot 3.x),
GitHub Actions (build, deploy, cleanup, pages), and helper PowerShell scripts to automate staged uploads and PRs.

GCP Project ID: `java17-spring-boot-demo-47761`
Region: `asia-south1`

Run `scripts/init_upload.ps1` from the repo root after adding GitHub secrets:
- GCP_SERVICE_ACCOUNT_KEY (service account JSON)
- GH_TOKEN (personal access token, for PR automation)
