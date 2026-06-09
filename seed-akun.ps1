# seed-akun.ps1 — Inject multiple dummy accounts into service-auth for profiling purposes
# Run: powershell -ExecutionPolicy Bypass -File .\seed-akun.ps1

$REGISTER_URL = "http://localhost:8081/api/auth/register"
$TOTAL_ACCOUNTS = 50 # Ubah jumlah ini sesuai kebutuhan load test/profiling Anda

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   Yomu App - Profiling Account Seeder" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Mulai melakukan pendaftaran (registrasi) $TOTAL_ACCOUNTS akun..." -ForegroundColor Yellow

$success = 0
$failed = 0

for ($i = 1; $i -le $TOTAL_ACCOUNTS; $i++) {
    $username = "testuser$i"
    $email = "testuser$i@yomu.local"
    $displayName = "Test User $i"
    $password = "password123"

    $registerPayload = @{
        username = $username
        email = $email
        displayName = $displayName
        password = $password
    } | ConvertTo-Json

    try {
        $response = Invoke-WebRequest -Uri $REGISTER_URL -Method POST -Body ([System.Text.Encoding]::UTF8.GetBytes($registerPayload)) -ContentType "application/json" -UseBasicParsing
        Write-Host "[OK] Berhasil register: $username" -ForegroundColor Green
        $success++
    } catch {
        # Jika status code 400 (sudah ada), kita anggap skip saja
        if ($_.Exception.Response.StatusCode -eq 400) {
            Write-Host "[SKIP] Akun sudah terdaftar: $username" -ForegroundColor DarkGray
        } else {
            Write-Host "[FAIL] Gagal register ${username}: $($_.Exception.Message)" -ForegroundColor Red
            $failed++
        }
    }
}

Write-Host "`n=== Seeding Akun Selesai ===" -ForegroundColor Cyan
Write-Host "Success: $success | Failed: $failed" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Yellow" })
