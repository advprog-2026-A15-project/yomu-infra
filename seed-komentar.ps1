# seed-komentar.ps1 — Inject sample comments into service-forum
# Run: powershell -ExecutionPolicy Bypass -File .\seed-komentar.ps1

$AUTH_URL = "http://localhost:8081/api/auth/login"
$BACAAN_URL = "http://localhost:8082/api/learning/bacaan"
$FORUM_URL = "http://localhost:8084/api/forum/comments"

Write-Host "Registering test user..." -ForegroundColor Cyan
$registerPayload = @{
    username = "testuser"
    email = "testuser@example.com"
    password = "password123"
} | ConvertTo-Json

try {
    Invoke-WebRequest -Uri "http://localhost:8081/api/auth/register" -Method POST -Body ([System.Text.Encoding]::UTF8.GetBytes($registerPayload)) -ContentType "application/json" -UseBasicParsing -TimeoutSec 15
    Write-Host "Test user registered!" -ForegroundColor Green
} catch {
    Write-Host "Test user might already exist. Proceeding to login..." -ForegroundColor Yellow
}

Write-Host "Logging in..." -ForegroundColor Cyan
$loginPayload = @{
    identifier = "testuser@example.com"
    password = "password123"
} | ConvertTo-Json

try {
    $authResponse = Invoke-WebRequest -Uri $AUTH_URL -Method POST -Body ([System.Text.Encoding]::UTF8.GetBytes($loginPayload)) -ContentType "application/json" -UseBasicParsing -TimeoutSec 15
    $tokenInfo = $authResponse.Content | ConvertFrom-Json
    $token = $tokenInfo.token
    Write-Host "Login berhasil, token didapatkan!" -ForegroundColor Green
} catch {
    Write-Host "Gagal login. Pastikan Auth Service berjalan dan data user ada." -ForegroundColor Red
    Write-Host "Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    
    $stream = $_.Exception.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($stream)
    $responseBody = $reader.ReadToEnd()
    Write-Host "Response Body: $responseBody" -ForegroundColor Red
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type"  = "application/json; charset=utf-8"
}

Write-Host "Fetching existing bacaan..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri $BACAAN_URL -Method GET -UseBasicParsing -TimeoutSec 15
    $bacaanList = $response.Content | ConvertFrom-Json
} catch {
    Write-Host "Gagal mengambil daftar bacaan: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

if ($bacaanList.Length -eq 0) {
    Write-Host "Tidak ada bacaan, jalankan seed-bacaan.ps1 terlebih dahulu." -ForegroundColor Yellow
    exit 0
}

$success = 0
$failed = 0

foreach ($bacaan in $bacaanList) {
    Write-Host "Menambahkan komentar untuk bacaan: $($bacaan.title)" -ForegroundColor Cyan
    
    $comments = @(
        @{
            bacaanId = $bacaan.id
            commentContent = "Artikel yang sangat informatif dan membuka wawasan!"
            parentComment = $null
        },
        @{
            bacaanId = $bacaan.id
            commentContent = "Saya suka dengan gaya penulisannya. Sangat mudah dipahami."
            parentComment = $null
        },
        @{
            bacaanId = $bacaan.id
            commentContent = "Apakah ada referensi lebih lanjut untuk topik ini?"
            parentComment = $null
        }
    )

    foreach ($c in $comments) {
        $json = $c | ConvertTo-Json -Depth 3
        try {
            $response = Invoke-WebRequest -Uri $FORUM_URL -Method POST -Headers $headers -Body ([System.Text.Encoding]::UTF8.GetBytes($json)) -UseBasicParsing -TimeoutSec 15
            $success++
        } catch {
            Write-Host "[FAIL] Gagal menambahkan komentar: $($_.Exception.Message)" -ForegroundColor Red
            $failed++
        }
    }
}

Write-Host "`n=== Seeding Komentar Complete ===" -ForegroundColor Cyan
Write-Host "Success: $success | Failed: $failed" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Yellow" })
