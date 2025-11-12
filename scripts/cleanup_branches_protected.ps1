$Token = $env:GH_TOKEN
if (-not $Token) { Write-Host "Set GH_TOKEN env var"; exit 1 }
$RepoUser = "shruti18j"; $RepoName="java17-springboot-example"; $Keep="main"
git fetch --all --prune
git branch | ForEach-Object { $b = $_.Trim(); if ($b -ne $Keep -and $b -ne "* $Keep") { git branch -D $b 2>$null } }
git branch -r | ForEach-Object { $rb = $_.Trim() -replace 'origin/',''; if ($rb -ne $Keep -and $rb -ne 'HEAD') { git push origin --delete $rb 2>$null } }
# close stale PRs
$headers=@{Authorization="token $Token"; "User-Agent"="PS"}; $prs=Invoke-RestMethod -Uri "https://api.github.com/repos/$RepoUser/$RepoName/pulls?state=open" -Headers $headers
foreach ($pr in $prs) { if ($pr.head.ref -ne $Keep) { Invoke-RestMethod -Uri "https://api.github.com/repos/$RepoUser/$RepoName/pulls/$($pr.number)" -Method PATCH -Headers $headers -Body (@{state="closed"}|ConvertTo-Json) } }
Write-Host "Cleanup done."
