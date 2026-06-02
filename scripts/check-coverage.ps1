<#
.SYNOPSIS
    Run tests + generate JaCoCo coverage report for each backend service.

.USAGE
    # Run all services:
    .\scripts\check-coverage.ps1

    # Run only specific services:
    .\scripts\check-coverage.ps1 -Services service-auth,service-forum

    # Skip test run (just parse existing reports):
    .\scripts\check-coverage.ps1 -SkipTests

    # Open HTML reports in browser after summary:
    .\scripts\check-coverage.ps1 -OpenReports
#>
param(
    [string[]]$Services = @(
        "service-auth",
        "service-learning",
        "service-achievements",
        "service-forum",
        "service-clan",
        "service-notification",
        "api-gateway",
        "shared-lib"
    ),
    [switch]$SkipTests,
    [switch]$OpenReports
)

$ErrorActionPreference = "Continue"
$Root = Split-Path -Parent $PSScriptRoot
$results = [System.Collections.Generic.List[PSCustomObject]]::new()

Write-Host ""
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "  YOMU - JaCoCo Coverage Check" -ForegroundColor Cyan
Write-Host "  $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""

foreach ($service in $Services) {
    $serviceDir = Join-Path $Root $service
    if (-not (Test-Path $serviceDir)) {
        Write-Host "[$service] SKIP — directory not found" -ForegroundColor Yellow
        $results.Add([PSCustomObject]@{
            Service    = $service
            Status     = "NOT FOUND"
            Instruction = "N/A"
            Branch      = "N/A"
            ReportPath  = "N/A"
        })
        continue
    }

    if (-not $SkipTests) {
        Write-Host "[$service] Running tests..." -ForegroundColor Cyan
        Push-Location $serviceDir
        try {
            # Use gradlew.bat on Windows, gradlew on Unix
            $gradlew = if (Test-Path ".\gradlew.bat") { ".\gradlew.bat" } else { ".\gradlew" }
            $proc = Start-Process -FilePath $gradlew -ArgumentList "test jacocoTestReport --no-daemon" `
                -Wait -PassThru -NoNewWindow -RedirectStandardOutput "$env:TEMP\yomu_gradle_out.txt" `
                -RedirectStandardError "$env:TEMP\yomu_gradle_err.txt"
            $exitCode = $proc.ExitCode
        } finally {
            Pop-Location
        }

        if ($exitCode -ne 0) {
            Write-Host "[$service] FAILED (exit $exitCode)" -ForegroundColor Red
            # Show last 10 lines of error output
            $errLines = Get-Content "$env:TEMP\yomu_gradle_err.txt" -Tail 10 -ErrorAction SilentlyContinue
            if ($errLines) { $errLines | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkRed } }
            $results.Add([PSCustomObject]@{
                Service     = $service
                Status      = "TEST FAILED"
                Instruction = "N/A"
                Branch      = "N/A"
                ReportPath  = "N/A"
            })
            continue
        }
        Write-Host "[$service] Tests passed" -ForegroundColor Green
    }

    # Parse JaCoCo XML report
    $xmlPath  = Join-Path $serviceDir "build\reports\jacoco\test\jacocoTestReport.xml"
    $htmlPath = Join-Path $serviceDir "build\reports\jacoco\test\html\index.html"

    if (-not (Test-Path $xmlPath)) {
        Write-Host "[$service] WARNING — XML report not found at $xmlPath" -ForegroundColor Yellow
        $results.Add([PSCustomObject]@{
            Service     = $service
            Status      = "NO REPORT"
            Instruction = "N/A"
            Branch      = "N/A"
            ReportPath  = "N/A"
        })
        continue
    }

    try {
        [xml]$jacoco = Get-Content $xmlPath -Raw
        $counters = $jacoco.report.counter

        $instrCounter   = $counters | Where-Object { $_.type -eq "INSTRUCTION" } | Select-Object -First 1
        $branchCounter  = $counters | Where-Object { $_.type -eq "BRANCH" }      | Select-Object -First 1

        function Get-Pct($counter) {
            if (-not $counter) { return "N/A" }
            $cov  = [double]$counter.covered
            $miss = [double]$counter.missed
            $tot  = $cov + $miss
            if ($tot -eq 0) { return "N/A (no data)" }
            $pct = [math]::Round(($cov / $tot) * 100, 1)
            return "$pct% ($([int]$cov)/$([int]$tot))"
        }

        $instrPct  = Get-Pct $instrCounter
        $branchPct = Get-Pct $branchCounter

        $statusColor = if ($instrPct -match "^(\d+\.\d+)") {
            $pctVal = [double]$Matches[1]
            if ($pctVal -ge 80) { "Green" } elseif ($pctVal -ge 60) { "Yellow" } else { "Red" }
        } else { "Yellow" }

        Write-Host "[$service] Instruction: $instrPct  |  Branch: $branchPct" -ForegroundColor $statusColor

        $results.Add([PSCustomObject]@{
            Service     = $service
            Status      = "OK"
            Instruction = $instrPct
            Branch      = $branchPct
            ReportPath  = $htmlPath
        })
    } catch {
        Write-Host "[$service] ERROR parsing XML: $_" -ForegroundColor Red
        $results.Add([PSCustomObject]@{
            Service     = $service
            Status      = "PARSE ERROR"
            Instruction = "N/A"
            Branch      = "N/A"
            ReportPath  = $htmlPath
        })
    }
}

Write-Host ""
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "  SUMMARY" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
$results | Format-Table Service, Status, Instruction, Branch -AutoSize

Write-Host "HTML reports:"
foreach ($r in $results) {
    if ($r.ReportPath -ne "N/A" -and (Test-Path $r.ReportPath)) {
        Write-Host "  $($r.Service): $($r.ReportPath)"
        if ($OpenReports) {
            Start-Process $r.ReportPath
        }
    }
}
Write-Host ""
