Param()
$RepoUrl = "https://github.com/shruti18j/java17-springboot-example.git"
$Main = "main"
$Token = $env:GH_TOKEN
if (-not $Token) { Write-Host "GH_TOKEN env var required for PR automation"; exit 1 }
if (-not (Test-Path ".git")) { git init; git branch -M $Main }
git remote remove origin 2>$null; git remote add origin $RepoUrl
git add .; git commit -m "feat: import Java17 Spring Boot final v4" 2>$null
git push -u origin $Main -f
# run staged steps and auto-merge after CI success (simple polling)
$scripts = ".\scripts\upload_step.ps1"
for ($step=1; $step -le 5; $step++) {
  Write-Host "Running upload step $step"
  & $scripts $step
  Start-Sleep -Seconds 10
  # Find PR for branch
  $branches = @{1="feature/setup-ci";2="feature/orgapp";3="feature/fileupload";4="feature/orders";5="feature/final"}
  $b = $branches[$step]
  Write-Host "Polling workflow runs for branch $b (waiting for success)"
  $repoApi = "https://api.github.com/repos/shruti18j/java17-springboot-example"
  $headers = @{ Authorization = "token $Token"; "User-Agent"="PS" }
  for ($i=0; $i -lt 60; $i++) {
    $runs = Invoke-RestMethod -Uri "$repoApi/actions/runs?branch=$b" -Headers $headers
    if ($runs.workflow_runs.Count -gt 0) {
      $latest = $runs.workflow_runs | Sort-Object created_at -Descending | Select-Object -First 1
      Write-Host "Latest run status: $($latest.status) conclusion: $($latest.conclusion)"
      if ($latest.conclusion -eq "success") {
        # merge PR if exists
        try {
          $prs = Invoke-RestMethod -Uri "$repoApi/pulls?state=open&head=shruti18j:$b" -Headers $headers
          if ($prs.Count -gt 0) {
            $prNum = $prs[0].number
            Invoke-RestMethod -Uri "$repoApi/pulls/$prNum/merge" -Method PUT -Headers $headers -Body (@{commit_title="auto-merge $b"}|ConvertTo-Json)
            Write-Host "Auto-merged PR #$prNum for $b"
          } else { Write-Host "No open PR found to merge." }
        } catch { Write-Host "Merge failed or not required: $_" }
        break
      } elseif ($latest.conclusion -eq "failure") { Write-Host "Build failed for $b"; break }
    }
    Start-Sleep -Seconds 15
  }
}
Write-Host "All staged uploads completed."
