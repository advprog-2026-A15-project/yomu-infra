#!/usr/bin/env bash
set -euo pipefail

# seed-kuis.sh - Inject sample quiz questions into service-learning
# Run: bash seed-kuis.sh

BACAAN_URL="${BACAAN_URL:-http://localhost:8082/api/learning/bacaan}"
QUESTIONS_URL="${QUESTIONS_URL:-http://localhost:8082/api/learning/questions}"

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Missing required command: $1" >&2
        exit 1
    fi
}

find_python() {
    is_python3() {
        "$1" -c 'import sys; raise SystemExit(0 if sys.version_info[0] >= 3 else 1)' >/dev/null 2>&1
    }

    if [[ -n "${PYTHON_BIN:-}" ]]; then
        if ! command -v "$PYTHON_BIN" >/dev/null 2>&1 || ! is_python3 "$PYTHON_BIN"; then
            echo "PYTHON_BIN must point to a Python 3 executable" >&2
            exit 1
        fi
        return
    fi

    for candidate in python3 python; do
        if command -v "$candidate" >/dev/null 2>&1 && is_python3 "$candidate"; then
            PYTHON_BIN="$candidate"
            return
        fi
    done

    echo "Missing required command: python3, or python pointing to Python 3" >&2
    exit 1
}

require_command curl
find_python

bacaan_file="$(mktemp)"
payloads_file="$(mktemp)"
trap 'rm -f "$bacaan_file" "$payloads_file" "${response_file:-}"' EXIT

echo "Fetching existing bacaan..."
if ! status="$(curl -sS -X GET "$BACAAN_URL" --max-time 15 -o "$bacaan_file" -w "%{http_code}")"; then
    echo "Gagal mengambil daftar bacaan: curl request failed" >&2
    exit 1
fi

if [[ "$status" != 2* ]]; then
    echo "Gagal mengambil daftar bacaan: HTTP $status $(<"$bacaan_file")" >&2
    exit 1
fi

"$PYTHON_BIN" - "$bacaan_file" <<'PY' > "$payloads_file"
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    bacaan_list = json.load(handle)

if not isinstance(bacaan_list, list):
    raise SystemExit("Expected bacaan response to be a JSON array")

for bacaan in bacaan_list:
    bacaan_id = str(bacaan["id"])
    title = bacaan.get("title", "")
    questions = [
        {
            "bacaanId": bacaan_id,
            "questionText": "Manakah dari berikut ini yang merupakan gagasan utama dari teks di atas?",
            "optionA": "Penjelasan mendetail mengenai sejarah topik",
            "optionB": "Dampak utama dari topik yang dibahas",
            "optionC": "Pendapat penulis tentang fenomena tersebut",
            "optionD": "Tidak ada jawaban yang benar",
            "correctOption": "B",
        },
        {
            "bacaanId": bacaan_id,
            "questionText": "Siapa atau apa yang menjadi fokus utama dalam paragraf pertama?",
            "optionA": "Tokoh utama atau subjek",
            "optionB": "Latar belakang sejarah",
            "optionC": "Kesimpulan dari cerita",
            "optionD": "Metode penelitian",
            "correctOption": "A",
        },
        {
            "bacaanId": bacaan_id,
            "questionText": "Menurut teks, apa kesimpulan yang dapat diambil?",
            "optionA": "Pentingnya mempelajari masa lalu",
            "optionB": "Teknologi akan menggantikan manusia sepenuhnya",
            "optionC": "Setiap usaha pasti membuahkan hasil",
            "optionD": "Pengetahuan dan kerja sama adalah kunci keberhasilan",
            "correctOption": "D",
        },
    ]

    for index, payload in enumerate(questions):
        print(json.dumps({"title": title, "index": index, "payload": payload}, ensure_ascii=False))
PY

if [[ ! -s "$payloads_file" ]]; then
    echo "Tidak ada bacaan, jalankan seed-bacaan.ps1 atau seed-bacaan.sh terlebih dahulu."
    exit 0
fi

success=0
failed=0
current_title=""

while IFS= read -r item; do
    title="$(printf '%s' "$item" | "$PYTHON_BIN" -c 'import json, sys; print(json.load(sys.stdin)["title"])')"
    payload="$(printf '%s' "$item" | "$PYTHON_BIN" -c 'import json, sys; print(json.dumps(json.load(sys.stdin)["payload"], ensure_ascii=False))')"

    if [[ "$title" != "$current_title" ]]; then
        echo "Menambahkan kuis untuk bacaan: $title"
        current_title="$title"
    fi

    response_file="$(mktemp)"
    if status="$(
        curl -sS -X POST "$QUESTIONS_URL" \
            -H "Content-Type: application/json; charset=utf-8" \
            --data-binary "$payload" \
            --max-time 15 \
            -o "$response_file" \
            -w "%{http_code}"
    )"; then
        if [[ "$status" == 2* ]]; then
            success=$((success + 1))
        else
            echo "[FAIL] Gagal menambahkan soal kuis: HTTP $status $(<"$response_file")"
            failed=$((failed + 1))
        fi
    else
        echo "[FAIL] Gagal menambahkan soal kuis: curl request failed"
        failed=$((failed + 1))
    fi

    rm -f "$response_file"
done < "$payloads_file"

echo
echo "=== Seeding Kuis Complete ==="
echo "Success: $success | Failed: $failed"
