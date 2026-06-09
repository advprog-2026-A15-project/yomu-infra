#!/usr/bin/env bash
set -euo pipefail

# seed-liga.sh - Inject sample clan data into service-clan
# Run: bash seed-liga.sh

BASE_URL="${BASE_URL:-http://localhost:8085/api/clan}"

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

new_uuid() {
    if command -v uuidgen >/dev/null 2>&1; then
        uuidgen
    elif [[ -r /proc/sys/kernel/random/uuid ]]; then
        cat /proc/sys/kernel/random/uuid
    else
        "$PYTHON_BIN" -c 'import uuid; print(uuid.uuid4())'
    fi
}

clan_json() {
    "$PYTHON_BIN" - "$1" "$2" "$3" <<'PY'
import json
import sys

payload = {
    "name": sys.argv[1],
    "description": sys.argv[2],
    "leaderId": sys.argv[3],
}
print(json.dumps(payload, ensure_ascii=False))
PY
}

require_command curl
find_python

clans_file="$(mktemp)"
rows_file="$(mktemp)"
trap 'rm -f "$clans_file" "$rows_file" "${response_file:-}"' EXIT

declare -A CLAN_DESCRIPTIONS=(
    ["Nusantara Elite"]="Para pembaca terbaik dari seluruh Nusantara."
    ["Literasi Juara"]="Membaca adalah jendela dunia."
    ["Pujangga Sakti"]="Kumpulan pecinta sastra dan puisi."
    ["Pasukan Kutu Buku"]="Buku adalah teman sejati kami."
    ["Garuda Membaca"]="Terbang tinggi dengan ilmu pengetahuan."
    ["Pelita Hati"]="Menerangi jalan dengan wawasan."
    ["Cahaya Ilmu"]="Mencari ilmu sampai ke ujung dunia."
    ["Pemikir Kritis"]="Menganalisis setiap kata dan makna."
    ["Pembelajar Cepat"]="Menyerap informasi secepat kilat."
    ["Generasi Emas"]="Mempersiapkan masa depan yang cerah."
)

declare -A CLAN_SCORES=(
    ["Nusantara Elite"]=5000
    ["Literasi Juara"]=4000
    ["Pujangga Sakti"]=3000
    ["Pasukan Kutu Buku"]=2500
    ["Garuda Membaca"]=2000
    ["Pelita Hati"]=1500
    ["Cahaya Ilmu"]=1000
    ["Pemikir Kritis"]=500
    ["Pembelajar Cepat"]=200
    ["Generasi Emas"]=100
)

CLAN_NAMES=(
    "Nusantara Elite"
    "Literasi Juara"
    "Pujangga Sakti"
    "Pasukan Kutu Buku"
    "Garuda Membaca"
    "Pelita Hati"
    "Cahaya Ilmu"
    "Pemikir Kritis"
    "Pembelajar Cepat"
    "Generasi Emas"
)

echo
echo "=== Seeding Liga Data ==="

for name in "${CLAN_NAMES[@]}"; do
    leader_id="$(new_uuid)"
    body="$(clan_json "$name" "${CLAN_DESCRIPTIONS[$name]}" "$leader_id")"
    response_file="$(mktemp)"

    if status="$(
        curl -sS -X POST "$BASE_URL" \
            -H "Authorization: Bearer $AUTH_TOKEN" \
            -H "Content-Type: application/json" \
            --data-binary "$body" \
            -o "$response_file" \
            -w "%{http_code}"
    )"; then
        if [[ "$status" == 2* ]]; then
            created_name="$("$PYTHON_BIN" -c 'import json, sys; print(json.load(sys.stdin).get("name", ""))' < "$response_file" 2>/dev/null || true)"
            echo "[OK] Created Clan: $created_name"
        fi
    fi

    rm -f "$response_file"
done

if status="$(curl -sS -X GET "$BASE_URL/leaderboard" -H "Authorization: Bearer $AUTH_TOKEN" -o "$clans_file" -w "%{http_code}")"; then
    if [[ "$status" == 2* ]]; then
        "$PYTHON_BIN" - "$clans_file" <<'PY' > "$rows_file"
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    clans = json.load(handle)

if not isinstance(clans, list):
    raise SystemExit("Expected leaderboard response to be a JSON array")

for clan in clans:
    print(json.dumps({"id": str(clan["id"]), "name": clan.get("name", "")}, ensure_ascii=False))
PY

        while IFS= read -r clan_row; do
            clan_id="$(printf '%s' "$clan_row" | "$PYTHON_BIN" -c 'import json, sys; print(json.load(sys.stdin)["id"])')"
            name="$(printf '%s' "$clan_row" | "$PYTHON_BIN" -c 'import json, sys; print(json.load(sys.stdin)["name"])')"
            score="${CLAN_SCORES[$name]:-100}"
            response_file="$(mktemp)"

            if status="$(
                curl -sS -X POST "$BASE_URL/$clan_id/admin/add-score?score=$score" \
                    -H "Authorization: Bearer $AUTH_TOKEN" \
                    -o "$response_file" \
                    -w "%{http_code}"
            )"; then
                if [[ "$status" == 2* ]]; then
                    echo "[OK] Added $score score to Clan: $name"
                else
                    echo "[FAIL] Add Score $name: HTTP $status $(<"$response_file")"
                fi
            else
                echo "[FAIL] Add Score $name: curl request failed"
            fi

            rm -f "$response_file"
        done < "$rows_file"
    else
        echo "[FAIL] Fetch Leaderboard: HTTP $status $(<"$clans_file")"
    fi
else
    echo "[FAIL] Fetch Leaderboard: curl request failed"
fi

echo
echo "=== Simulating Seasons (Promotions/Demotions) ==="
for i in 1 2 3 4; do
    response_file="$(mktemp)"
    if status="$(curl -sS -X POST "$BASE_URL/admin/end-season" -H "Authorization: Bearer $AUTH_TOKEN" -o "$response_file" -w "%{http_code}")"; then
        if [[ "$status" == 2* ]]; then
            echo "[OK] Season $i ended."
            sleep 1
        else
            echo "[FAIL] End Season $i: HTTP $status $(<"$response_file")"
        fi
    else
        echo "[FAIL] End Season $i: curl request failed"
    fi
    rm -f "$response_file"
done

echo
echo "=== Seeding Complete ==="
