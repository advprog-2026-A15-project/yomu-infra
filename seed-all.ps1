# seed-all.ps1 - Run all seed scripts in the correct order
# Run: powershell -ExecutionPolicy Bypass -File .\seed-all.ps1

$ErrorActionPreference = "Stop"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "       Yomu App - Data Seeding" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

$scripts = @(
    "seed-liga.ps1",
    "seed-bacaan.ps1",
    "seed-kuis.ps1",
    "seed-komentar.ps1"
)

foreach ($script in $scripts) {
    if (Test-Path .\$script) {
        Write-Host "`n>>> Running $script..." -ForegroundColor Yellow
        try {
            powershell -ExecutionPolicy Bypass -File .\$script
            if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne $null) {
                Write-Host ">>> Warning: $script finished with exit code $LASTEXITCODE" -ForegroundColor Red
            }
        } catch {
            Write-Host ">>> Error executing $script: $($_.Exception.Message)" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "`n>>> Warning: $script not found. Skipping." -ForegroundColor Red
    }
}

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "    All Data Seeding Scripts Completed!" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
