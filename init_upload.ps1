# ================================================
# init_upload.ps1
# Orchestrates staged upload & CI/CD auto-merge
# ================================================

param(
    [string]$RepoOwner = "shruti18j",
    [string]$RepoName = "java17-springboot-example"
)

$MainBranch = "main"
$Token = $env:GH_TOKEN
if (-not $Token) {
    Write-Host "❌ Missing GitHub Token. Please set GH_TOKEN environment variable." -ForegroundColor Red
    exit 1
}

$Headers = @{
    Authorization = "token $Token"
    "User-Agent"  = "PowerShell"
    Accept        = "application/vnd.github+json"
}

function Wait-ForBuild($branch) {
    $MaxRetries = 20
    $DelaySec = 30
    $Attempts = 0

    Write-Host "⏳ Polling workflow runs for branch $branch (waiting for success)..."

    while ($Attempts -lt $MaxRetries) {
        Start-Sleep -Seconds $DelaySec
        $url = "https://api.github.com/repos/$RepoOwner/$RepoName/actions/runs?branch=$branch&per_page=1"
        $resp = Invoke-RestMethod -Uri $url -Headers $Headers -ErrorAction SilentlyContinue

        if ($null -ne $resp.workflow_runs -and $resp.workflow_runs.Count -gt 0) {
            $run = $resp.workflow_runs[0]
            $status = $run.status
            $conclusion = $run.conclusion

            Write-Host "🧩 Latest run status: $status | conclusion: $conclusion"

            if ($status -eq "completed") {
                if ($conclusion -eq "success") {
                    Write-Host "✅ Build successful for $branch!"
                    return $true
                } else {
                    Write-Host "❌ Build failed for $branch (conclusion=$conclusion)."
                    return $false
                }
            }
        }

        $Attempts++
    }

    Write-Host "⚠️ Timeout waiting for build on $branch after $($MaxRetries * $DelaySec / 60) minutes."
    return $false
}

function Merge-PR($branch) {
    Write-Host "🔍 Checking for open PRs for $branch..."
    # fixed URL encoding
    $prUrl = "https://api.github.com/repos/$RepoOwner/$RepoName/pulls?state=open`&head=$($RepoOwner):$($branch)"
    $prList = Invoke-RestMethod -Uri $prUrl -Headers $Headers -ErrorAction SilentlyContinue

    if ($prList.Count -gt 0) {
        $pr = $prList[0]
        $mergeUrl = "https://api.github.com/repos/$RepoOwner/$RepoName/pulls/$($pr.number)/merge"
        Write-Host "🔄 Merging PR #$($pr.number) ($($pr.title))..."
        try {
            Invoke-RestMethod -Uri $mergeUrl -Method PUT -Headers $Headers -Body '{"merge_method":"squash"}'
            Write-Host "✅ PR merged successfully!"
            return $true
        } catch {
            Write-Host "⚠️ Merge failed: $_"
        }
    } else {
        Write-Host "ℹ️ No open PR found to merge for $branch."
    }
    return $false
}

function Run-UploadStep($step) {
    Write-Host "`n🚀 Running upload step $step..."
    & ".\scripts\upload_step.ps1" -Step $step

    switch ($step) {
        1 { $branch = "feature/setup-ci" }
        2 { $branch = "feature/orgapp" }
        3 { $branch = "feature/fileupload" }
        4 { $branch = "feature/orders" }
        5 { $branch = "feature/final" }
    }

    $success = Wait-ForBuild $branch
    if (-not $success) {
        Write-Host "🔁 Retrying build once for $branch..."
        Start-Sleep -Seconds 30
        $success = Wait-ForBuild $branch
    }

    if ($success) {
        Merge-PR $branch | Out-Null
    } else {
        Write-Host "⚠️ Skipping merge for $branch due to failed build."
    }
}

git fetch origin $MainBranch
git checkout $MainBranch
git pull origin $MainBranch

1..5 | ForEach-Object { Run-UploadStep $_ }

Write-Host "`n🎉 All staged uploads processed successfully!"
Write-Host "👉 Check Actions: https://github.com/$RepoOwner/$RepoName/actions"
Write-Host "👉 Check Pull Requests: https://github.com/$RepoOwner/$RepoName/pulls"
