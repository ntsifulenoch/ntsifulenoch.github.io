<#
.SYNOPSIS
  Compile the CV (cv\resume_ntsiful.tex) into files\Enoch_Ntsiful_CV.pdf for the website.

.DESCRIPTION
  Uses MiKTeX's pdflatex. LaTeX's auxiliary files go to a temp folder, never into OneDrive.
  To move edits between this computer, GitHub and Overleaf, use scripts\sync.ps1
  (it calls this script).

  If Windows blocks scripts, run it as:
    powershell -ExecutionPolicy Bypass -File scripts\cv.ps1
#>

$root = Split-Path -Parent $PSScriptRoot
$cv   = Join-Path $root "cv"
$tex  = "resume_ntsiful.tex"
$pdf  = Join-Path $root "files\Enoch_Ntsiful_CV.pdf"
$out  = Join-Path $env:TEMP "cv-build"

if (-not (Test-Path (Join-Path $cv $tex))) { Write-Error "Cannot find $cv\$tex"; exit 1 }

# Reproducible PDF: the same source gives a byte-identical PDF, so a sync with no CV
# changes does not create an empty "Rebuild CV PDF" commit.
$epoch = git -C $root log -1 --format=%ct -- cv 2>$null
if ($epoch) { $env:SOURCE_DATE_EPOCH = $epoch; $env:FORCE_SOURCE_DATE = "1" }

Write-Host "==> Compiling $tex"
New-Item -ItemType Directory -Force $out | Out-Null
Push-Location $cv
try {
  foreach ($pass in 1..2) {
    pdflatex -interaction=nonstopmode -halt-on-error "-output-directory=$out" $tex | Out-Null
    if ($LASTEXITCODE -ne 0) { Write-Error "pdflatex failed; see $out\resume_ntsiful.log"; exit 1 }
  }
} finally {
  Pop-Location
}
Copy-Item (Join-Path $out "resume_ntsiful.pdf") $pdf -Force
Write-Host "    files\Enoch_Ntsiful_CV.pdf updated"
exit 0
