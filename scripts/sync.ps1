<#
.SYNOPSIS
  Two-way sync between this computer, GitHub (the website) and Overleaf (the CV).

.DESCRIPTION
  Run it after editing in any of the three places:
    - on github.com (any page, or cv/resume_ntsiful.tex)
    - on Overleaf (the CV)
    - on this computer

  What it does:
    1. Saves (commits) the edits made on this computer.
    2. Brings down the edits made on GitHub.
    3. Brings down the CV edits made on Overleaf (into cv/).
    4. Rebuilds the CV PDF for the website.
    5. Sends everything to GitHub (the website rebuilds itself) and the CV to Overleaf.

  If the same lines were edited in two places, it stops and says so. Nothing is lost;
  resolve the lines git lists (or ask Claude), then run it again.

  Usage, from this folder:
    powershell -ExecutionPolicy Bypass -File scripts\sync.ps1 -Message "Fix typo on Research page"
#>
param([string]$Message = "Update website")

$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

function Stop-Sync([string]$why) {
  Write-Host ""
  Write-Host "STOPPED: $why" -ForegroundColor Yellow
  exit 1
}

# 1. Save the edits made on this computer
git add -A
git diff --cached --quiet
if ($LASTEXITCODE -ne 0) {
  Write-Host "==> Saving your edits on this computer"
  git commit -q -m $Message
  if ($LASTEXITCODE -ne 0) { Stop-Sync "could not commit your edits." }
}

# 2. GitHub -> this computer
$hasGitHub = (git remote) -contains "origin"
if ($hasGitHub) {
  Write-Host "==> Bringing down edits made on GitHub"
  git pull --no-rebase --no-edit origin master
  if ($LASTEXITCODE -ne 0) { Stop-Sync "edits on GitHub overlap with edits here. Resolve the files git lists, then run this again." }
}

# 3. Overleaf -> this computer (cv/)
Write-Host "==> Bringing down CV edits made on Overleaf"
git subtree pull --prefix=cv overleaf main -m "Merge CV edits from Overleaf"
if ($LASTEXITCODE -ne 0) { Stop-Sync "CV edits on Overleaf overlap with edits here. Resolve the files git lists, then run this again." }

# 4. Rebuild the CV PDF and save it if it changed
& (Join-Path $PSScriptRoot "cv.ps1")
if ($LASTEXITCODE -ne 0) { Stop-Sync "the CV did not compile (see the log path above)." }
git add files/Enoch_Ntsiful_CV.pdf
git diff --cached --quiet
if ($LASTEXITCODE -ne 0) {
  git commit -q -m "Rebuild CV PDF"
  if ($LASTEXITCODE -ne 0) { Stop-Sync "could not commit the rebuilt CV PDF." }
}

# 5. This computer -> Overleaf (the CV), then GitHub
#    "split --rejoin" records what was sent to Overleaf in this history, so the next
#    sync does not pull it back as an empty merge.
Write-Host "==> Sending the CV to Overleaf"
$split = git subtree split --prefix=cv --rejoin
if ($LASTEXITCODE -ne 0 -or -not $split) { Stop-Sync "could not prepare the CV for Overleaf." }
$split = ([string]($split | Select-Object -Last 1)).Trim()
git push overleaf "${split}:main"
if ($LASTEXITCODE -ne 0) { Stop-Sync "the push to Overleaf failed. If the CV was edited on Overleaf meanwhile, run this again." }

if ($hasGitHub) {
  Write-Host "==> Sending everything to GitHub"
  git push origin master
  if ($LASTEXITCODE -ne 0) { Stop-Sync "the push to GitHub failed." }
}

Write-Host ""
Write-Host "In sync: this computer, GitHub and Overleaf." -ForegroundColor Green
