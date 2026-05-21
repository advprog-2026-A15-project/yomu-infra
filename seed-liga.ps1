# seed-liga.ps1 — Inject sample clan data into service-clan
# Run: powershell -ExecutionPolicy Bypass -File .\seed-liga.ps1

$BASE_URL = "http://localhost:8085/api/clan"

$clansToCreate = @(
    @{ name = "Nusantara Elite"; desc = "Para pembaca terbaik dari seluruh Nusantara."; score = 5000 }
    @{ name = "Literasi Juara"; desc = "Membaca adalah jendela dunia."; score = 4000 }
    @{ name = "Pujangga Sakti"; desc = "Kumpulan pecinta sastra dan puisi."; score = 3000 }
    @{ name = "Pasukan Kutu Buku"; desc = "Buku adalah teman sejati kami."; score = 2500 }
    @{ name = "Garuda Membaca"; desc = "Terbang tinggi dengan ilmu pengetahuan."; score = 2000 }
    @{ name = "Pelita Hati"; desc = "Menerangi jalan dengan wawasan."; score = 1500 }
    @{ name = "Cahaya Ilmu"; desc = "Mencari ilmu sampai ke ujung dunia."; score = 1000 }
    @{ name = "Pemikir Kritis"; desc = "Menganalisis setiap kata dan makna."; score = 500 }
    @{ name = "Pembelajar Cepat"; desc = "Menyerap informasi secepat kilat."; score = 200 }
    @{ name = "Generasi Emas"; desc = "Mempersiapkan masa depan yang cerah."; score = 100 }
)

Write-Host "`n=== Seeding Liga Data ===" -ForegroundColor Cyan

# Create Clans
foreach ($c in $clansToCreate) {
    $leaderId = [guid]::NewGuid().ToString()
    $body = @{
        name = $c.name
        description = $c.desc
        leaderId = $leaderId
    } | ConvertTo-Json

    try {
        $response = Invoke-WebRequest -Uri $BASE_URL -Method POST -Body ([System.Text.Encoding]::UTF8.GetBytes($body)) -ContentType "application/json" -UseBasicParsing
        $clan = $response.Content | ConvertFrom-Json
        Write-Host "[OK] Created Clan: $($clan.name)" -ForegroundColor Green
    } catch {
        # Ignore conflict
    }
}

# Fetch all clans and Add Scores
try {
    $allClansResp = Invoke-WebRequest -Uri "$BASE_URL/leaderboard" -Method GET -UseBasicParsing
    $allClans = $allClansResp.Content | ConvertFrom-Json
    foreach ($c in $allClans) {
        $score = 100
        foreach ($ct in $clansToCreate) {
            if ($ct.name -eq $c.name) { $score = $ct.score; break }
        }
        try {
            $url = "$BASE_URL/$($c.id)/admin/add-score?score=$($score)"
            $response = Invoke-WebRequest -Uri $url -Method POST -UseBasicParsing
            Write-Host "[OK] Added $score score to Clan: $($c.name)" -ForegroundColor Green
        } catch {
            Write-Host "[FAIL] Add Score $($c.name): $($_.Exception.Message)" -ForegroundColor Red
        }
    }
} catch {
     Write-Host "[FAIL] Fetch Leaderboard: $($_.Exception.Message)" -ForegroundColor Red
}

# Trigger End Seasons to distribute into divisions
Write-Host "`n=== Simulating Seasons (Promotions/Demotions) ===" -ForegroundColor Cyan
for ($i = 1; $i -le 4; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "$BASE_URL/admin/end-season" -Method POST -UseBasicParsing
        Write-Host "[OK] Season $($i) ended." -ForegroundColor Green
        Start-Sleep -Seconds 1
    } catch {
        Write-Host "[FAIL] End Season $($i): $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n=== Seeding Complete ===" -ForegroundColor Cyan
