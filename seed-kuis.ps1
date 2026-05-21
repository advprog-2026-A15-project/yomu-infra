# seed-kuis.ps1 — Inject sample quiz questions into service-learning
# Run: powershell -ExecutionPolicy Bypass -File .\seed-kuis.ps1

$BACAAN_URL = "http://localhost:8082/api/learning/bacaan"
$QUESTIONS_URL = "http://localhost:8082/api/learning/questions"

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
    Write-Host "Menambahkan kuis untuk bacaan: $($bacaan.title)" -ForegroundColor Cyan
    
    $questions = @(
        @{
            bacaanId = $bacaan.id
            questionText = "Manakah dari berikut ini yang merupakan gagasan utama dari teks di atas?"
            optionA = "Penjelasan mendetail mengenai sejarah topik"
            optionB = "Dampak utama dari topik yang dibahas"
            optionC = "Pendapat penulis tentang fenomena tersebut"
            optionD = "Tidak ada jawaban yang benar"
            correctOption = "B"
        },
        @{
            bacaanId = $bacaan.id
            questionText = "Siapa atau apa yang menjadi fokus utama dalam paragraf pertama?"
            optionA = "Tokoh utama atau subjek"
            optionB = "Latar belakang sejarah"
            optionC = "Kesimpulan dari cerita"
            optionD = "Metode penelitian"
            correctOption = "A"
        },
        @{
            bacaanId = $bacaan.id
            questionText = "Menurut teks, apa kesimpulan yang dapat diambil?"
            optionA = "Pentingnya mempelajari masa lalu"
            optionB = "Teknologi akan menggantikan manusia sepenuhnya"
            optionC = "Setiap usaha pasti membuahkan hasil"
            optionD = "Pengetahuan dan kerja sama adalah kunci keberhasilan"
            correctOption = "D"
        }
    )

    foreach ($q in $questions) {
        $json = $q | ConvertTo-Json -Depth 3
        try {
            $response = Invoke-WebRequest -Uri $QUESTIONS_URL -Method POST -Body ([System.Text.Encoding]::UTF8.GetBytes($json)) -ContentType "application/json; charset=utf-8" -UseBasicParsing -TimeoutSec 15
            $success++
        } catch {
            Write-Host "[FAIL] Gagal menambahkan soal kuis: $($_.Exception.Message)" -ForegroundColor Red
            $failed++
        }
    }
}

Write-Host "`n=== Seeding Kuis Complete ===" -ForegroundColor Cyan
Write-Host "Success: $success | Failed: $failed" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Yellow" })
