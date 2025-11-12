param()
$RepoOwner = "shruti18j"
$RepoName = "java17-springboot-example"
$MainBranch = "main"
$Token = $env:GH_TOKEN
if (-not $Token) { Write-Host "Missing GH_TOKEN env var"; exit 1 }
$Headers = @{ Authorization = "token $Token"; "User-Agent" = "PowerShell"; Accept = "application/vnd.github+json" }

function Wait-ForBuild($branch) {
    $MaxRetries = 20; $DelaySec = 20; $Attempts = 0
    while ($Attempts -lt $MaxRetries) {
        Start-Sleep -Seconds $DelaySec
        $url = "https://api.github.com/repos/$RepoOwner/$RepoName/actions/runs?branch=$branch&per_page=1"
        $resp = Invoke-RestMethod -Uri $url -Headers $Headers -ErrorAction SilentlyContinue
        if ($null -ne $resp.workflow_runs -and $resp.workflow_runs.Count -gt 0) {
            $run = $resp.workflow_runs[0]
            if ($run.status -eq "completed") {
                if ($run.conclusion -eq "success") { return $true } else { return $false }
            }
        }
        $Attempts++
    }
    return $false
}

function Merge-PR($branch) {
    $prUrl = "https://api.github.com/repos/$RepoOwner/$RepoName/pulls?state=open`&head=$($RepoOwner):$($branch)"
    $prList = Invoke-RestMethod -Uri $prUrl -Headers $Headers -ErrorAction SilentlyContinue
    if ($prList -and $prList.Count -gt 0) {
        $pr = $prList[0]
        $mergeUrl = "https://api.github.com/repos/$RepoOwner/$RepoName/pulls/$($pr.number)/merge"
        try { Invoke-RestMethod -Uri $mergeUrl -Method PUT -Headers $Headers -Body '{"merge_method":"squash"}'; return $true } catch { return $false }
    }
    return $false
}

git fetch origin $MainBranch; git checkout $MainBranch; git pull origin $MainBranch

1..5 | ForEach-Object {
    Write-Host "Running upload step $_"
    & ".\scripts\upload_step.ps1" -Step $_
    $branch = switch ($_){1{"feature/setup-ci"}2{"feature/orgapp"}3{"feature/fileupload"}4{"feature/orders"}5{"feature/final"}}
    $ok = Wait-ForBuild $branch
    if (-not $ok) { Start-Sleep -Seconds 20; $ok = Wait-ForBuild $branch }
    if ($ok) { Merge-PR $branch | Out-Null; Write-Host "Merged $branch" } else { Write-Host "Build failed for $branch, skipping merge." }
}
