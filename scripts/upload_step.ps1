param([int]$Step = $(Read-Host "Enter upload step (1-5)"))
$RepoUrl = "https://github.com/shruti18j/java17-springboot-example.git"
$MainBranch = "main"
$GitHubUser = "shruti18j"
$RepoName = "java17-springboot-example"
$Token = $env:GH_TOKEN
if (-not $Token) { Write-Host "Missing GitHub Token. Please set GH_TOKEN env var"; exit 1 }
function Ensure-GitRepo { if (-not (Test-Path ".git")) { git init; git branch -M $MainBranch; git remote add origin $RepoUrl } }
function Switch-Or-CreateBranch($branch) { git fetch origin main 2>$null; if (git show-ref --verify --quiet "refs/heads/$branch") { git checkout $branch } else { git checkout -b $branch origin/main 2>$null || git checkout -b $branch } }
function Push-And-PR($branch, $message, $tag) {
  git add . 2>$null
  git commit -m $message 2>$null || Write-Host "Nothing to commit for $branch"
  git push origin $branch -u -f
  $body = @{ title=$message; head=$branch; base=$MainBranch; body="Auto PR created by upload_step.ps1" } | ConvertTo-Json
  try { $pr = Invoke-RestMethod -Uri "https://api.github.com/repos/$GitHubUser/$RepoName/pulls" -Method POST -Headers @{ Authorization = "token $Token"; "User-Agent"="PS" } -Body $body; Write-Host "PR: $($pr.html_url)"; } catch { Write-Host "PR exists or could not be created."; }
}
Ensure-GitRepo
switch ($Step) {
  1 { $b="feature/setup-ci"; Switch-Or-CreateBranch $b; git add .github docs pom.xml cloudbuild.yaml scripts/setup_gcp_env.ps1 GCP_SETUP.md 2>$null; Push-And-PR $b "chore: bootstrap CI/CD and docs" "v1.0.1-setup-ci" }
  2 { $b="feature/orgapp"; Switch-Or-CreateBranch $b; git add org-app 2>$null; Push-And-PR $b "feat: add OrgApp microservice" "v1.0.2-orgapp" }
  3 { $b="feature/fileupload"; Switch-Or-CreateBranch $b; git add file-upload-service 2>$null; Push-And-PR $b "feat: add File Upload microservice" "v1.0.3-fileupload" }
  4 { $b="feature/orders"; Switch-Or-CreateBranch $b; git add orders-kafka-service 2>$null; Push-And-PR $b "feat: add Orders Kafka+PubSub microservice" "v1.0.4-orders" }
  5 { $b="feature/final"; Switch-Or-CreateBranch $b; git add README.md orgapp_postman_collection.json 2>$null; Push-And-PR $b "docs: finalize docs and Postman collection" "v1.0.5-final" }
  default { Write-Host "Invalid step" }
}
