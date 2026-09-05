param([switch]$Upload)
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot
$files = @(Get-ChildItem -File -Filter *.pdf) + @(Get-ChildItem -Directory | Where-Object Name -NotLike '.*' | Get-ChildItem -File -Filter *.pdf)
$files = @($files | Sort-Object FullName)
if ($files | Where-Object Length -GE 50MB) { throw 'A PDF exceeds 50 MiB.' }
$batches = New-Object 'System.Collections.Generic.List[object]'
$currentBatch = @()
$batchBytes = 0L
foreach ($file in $files) {
    if ($batchBytes + $file.Length -gt 80MB -and $currentBatch.Count) {
        $batches.Add($currentBatch)
        $currentBatch = @()
        $batchBytes = 0L
    }
    $currentBatch += $file.FullName.Substring($PSScriptRoot.Length + 1)
    $batchBytes += $file.Length
}
if ($currentBatch.Count) { $batches.Add($currentBatch) }
Write-Host "PDFs: $($files.Count). Batches: $($batches.Count), at most 80 MiB each."
if (-not $Upload) {
    Write-Host 'Preview only. To commit and upload, run: .\UPLOAD-BOOKS.ps1 -Upload'
    return
}
$branch = git symbolic-ref --short HEAD
if ($LASTEXITCODE -ne 0 -or $branch -ne 'master') { throw 'Expected branch master.' }
$index = 0
foreach ($batch in $batches) {
    $index++
    if ($index -eq 1) {
        git add -- .gitattributes .gitignore README.md DJOSATTIS-CHECK.md LIPPMAN-CHECK.md parts-manifest.json UPLOAD-BOOKS.ps1
        if ($LASTEXITCODE -ne 0) { throw 'Cannot stage metadata.' }
    }
    git add -- @batch
    if ($LASTEXITCODE -ne 0) { throw 'Cannot stage PDFs.' }
    git diff --cached --quiet
    if ($LASTEXITCODE -eq 1) {
        git commit -m "books: batch $index of $($batches.Count)"
        if ($LASTEXITCODE -ne 0) { throw 'Commit failed.' }
    } elseif ($LASTEXITCODE -ne 0) { throw 'Cannot inspect index.' }
    git push -u origin master
    if ($LASTEXITCODE -ne 0) { throw 'Push failed. Resolve the error and run this script again.' }
}
Write-Host 'Upload complete.'
