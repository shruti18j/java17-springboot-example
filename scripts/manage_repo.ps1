param([string]$RepoOwner="shruti18j",[string]$RepoName="java17-springboot-example")
$Token = $env:GH_TOKEN
if (-not $Token) { Write-Host "Set GH_TOKEN env var"; exit 1 }
$Headers=@{Authorization="token $Token"; "User-Agent"="PowerShell"}
function Confirm($msg){ $r=Read-Host "$msg (Y/N)"; return $r -eq "Y" }
if (Confirm "Delete remote feature branches except main?") {
  $branches = Invoke-RestMethod -Uri "https://api.github.com/repos/$RepoOwner/$RepoName/branches" -Headers $Headers
  foreach ($b in $branches) { if ($b.name -ne "main") { if (Confirm "Delete $($b.name)?") { Invoke-RestMethod -Uri "https://api.github.com/repos/$RepoOwner/$RepoName/git/refs/heads/$($b.name)" -Method DELETE -Headers $Headers -ErrorAction SilentlyContinue; Write-Host "Deleted $($b.name)" } } }
}
if (Confirm "Run staged upload (init_upload.ps1)?") { & ".\scripts\init_upload.ps1" }
if (Confirm "Merge any open PRs now?") {
  $prs = Invoke-RestMethod -Uri "https://api.github.com/repos/$RepoOwner/$RepoName/pulls?state=open" -Headers $Headers
  foreach ($pr in $prs) { if (Confirm "Merge PR #$($pr.number) $($pr.title)?") { Invoke-RestMethod -Uri "https://api.github.com/repos/$RepoOwner/$RepoName/pulls/$($pr.number)/merge" -Method PUT -Headers $Headers -Body '{"merge_method":"squash"}' } }
}
Write-Host "Done"
