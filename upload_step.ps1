param(
    [int]$Step = $(Read-Host "Enter upload step (1-5)")
)

$RepoUrl = "https://github.com/shruti18j/java17-springboot-example.git"
$MainBranch = "main"
$GitHubUser = "shruti18j"
$RepoName = "java17-springboot-example"
$Token = $env:GH_TOKEN

if (-not $Token) {
    Write-Host "ERROR: Missing GitHub Token. Please run: setx GH_TOKEN 'your_token_here'"
    exit 1
}

function Ensure-GitRepo {
    if (-not (Test-Path ".git")) {
        Write-Host "Initializing new git repository..."
        git init
        git branch -M $MainBranch
        git remote add origin $RepoUrl
    }
}

function Switch-Or-CreateBranch($branch) {
    $exists = (git branch --list $branch)
    if ($exists) {
        Write-Host "Switching to branch $branch"
        git checkout $branch
    } else {
        Write-Host "Creating new branch $branch"
        git checkout -b $branch
    }
}

function Push-And-PR($branch, $message, $tag) {
    git add .
    git commit -m $message
    git push origin $branch -f
    Write-Host "Pushed branch $branch to GitHub"

    $prTitle = $message
    $prBody = "Auto-created PR for step: $branch -> $MainBranch"
    $createPrCmd = @{
        Uri = "https://api.github.com/repos/$GitHubUser/$RepoName/pulls"
        Method = "POST"
        Headers = @{ Authorization = "token $Token"; "User-Agent" = "PowerShell" }
        Body = @{ title = $prTitle; head = $branch; base = $MainBranch; body = $prBody } | ConvertTo-Json
    }

    $prResponse = Invoke-RestMethod @createPrCmd
    $prNumber = $prResponse.number
    Write-Host "PR created: https://github.com/$GitHubUser/$RepoName/pull/$prNumber"

    Write-Host "Waiting for CI build to complete..."
    Start-Sleep -Seconds 30

    for ($i = 0; $i -lt 30; $i++) {
        $runResponse = Invoke-RestMethod -Uri "https://api.github.com/repos/$GitHubUser/$RepoName/actions/runs?branch=$branch" -Headers @{ Authorization = "token $Token"; "User-Agent" = "PowerShell" }
        $latestRun = $runResponse.workflow_runs | Sort-Object -Property created_at -Descending | Select-Object -First 1

        if ($null -ne $latestRun) {
            if ($latestRun.conclusion -eq "success") {
                Write-Host "Build succeeded, merging PR..."
                $mergeCmd = @{
                    Uri = "https://api.github.com/repos/$GitHubUser/$RepoName/pulls/$prNumber/merge"
                    Method = "PUT"
                    Headers = @{ Authorization = "token $Token"; "User-Agent" = "PowerShell" }
                    Body = @{ commit_title = "auto-merge: $message" } | ConvertTo-Json
                }
                Invoke-RestMethod @mergeCmd
                git tag -a $tag -m $message
                git push origin $tag
                Write-Host "PR merged and tagged as $tag"
                return
            }
            elseif ($latestRun.conclusion -eq "failure") {
                Write-Host "Build failed, PR not merged."
                return
            }
        }
        Start-Sleep -Seconds 20
    }

    Write-Host "Timeout waiting for build completion."
}

Ensure-GitRepo

switch ($Step) {
    1 {
        $branch = "feature/setup-ci"
        Switch-Or-CreateBranch $branch
        git add .github docs pom.xml cloudbuild.yaml setup_gcp_env.ps1 GCP_SETUP.md
        Push-And-PR $branch "chore: bootstrap CI/CD and docs" "v1.0.1-setup-ci"
    }
    2 {
        $branch = "feature/orgapp"
        Switch-Or-CreateBranch $branch
        git add org-app
        Push-And-PR $branch "feat: add OrgApp microservice" "v1.0.2-orgapp"
    }
    3 {
        $branch = "feature/fileupload"
        Switch-Or-CreateBranch $branch
        git add file-upload-service
        Push-And-PR $branch "feat: add File Upload microservice" "v1.0.3-fileupload"
    }
    4 {
        $branch = "feature/orders"
        Switch-Or-CreateBranch $branch
        git add orders-kafka-service
        Push-And-PR $branch "feat: add Orders Kafka+PubSub microservice" "v1.0.4-orders"
    }
    5 {
        $branch = "feature/final"
        Switch-Or-CreateBranch $branch
        git add README.md post_upload_checklist.md orgapp_postman_collection.json
        Push-And-PR $branch "docs: finalize docs and Postman collection" "v1.0.5-final"
    }
    default {
        Write-Host "Invalid step. Please enter a number between 1 and 5."
    }
}
