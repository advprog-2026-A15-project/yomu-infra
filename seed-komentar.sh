#!/usr/bin/env bash
set -euo pipefail

# seed-komentar.sh - Inject sample comments into service-forum
# Run: bash seed-komentar.sh

AUTH_URL="${AUTH_URL:-http://localhost:8081/api/auth/login}"
REGISTER_URL="${REGISTER_URL:-http://localhost:8081/api/auth/register}"
BACAAN_URL="${BACAAN_URL:-http://localhost:8082/api/learning/bacaan}"
FORUM_URL="${FORUM_URL:-http://localhost:8084/api/forum/comments}"

SEED_USERNAME="${SEED_USERNAME:-seedkomentar}"
SEED_EMAIL="${SEED_EMAIL:-seed-komentar@yomu.local}"
SEED_PASSWORD="${SEED_PASSWORD:-password123}"
SEED_DISPLAY_NAME="${SEED_DISPLAY_NAME:-Seed Komentar User}"

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

json_field() {
    local field="$1"
    "$PYTHON_BIN" -c 'import json, sys; value = json.load(sys.stdin).get(sys.argv[1]); print("" if value is None else value)' "$field"
}

make_json() {
    "$PYTHON_BIN" - "$@" <<'PY'
import json
import sys

mode = sys.argv[1]
if mode == "register":
    payload = {
        "username": sys.argv[2],
        "email": sys.argv[3],
        "displayName": sys.argv[4],
        "password": sys.argv[5],
    }
elif mode == "login":
    payload = {
        "identifier": sys.argv[2],
        "password": sys.argv[3],
    }
else:
    raise SystemExit(f"Unknown payload mode: {mode}")

print(json.dumps(payload, ensure_ascii=False))
PY
}

require_command curl
find_python

register_response="$(mktemp)"
login_response="$(mktemp)"
bacaan_file="$(mktemp)"
payloads_file="$(mktemp)"
trap 'rm -f "$register_response" "$login_response" "$bacaan_file" "$payloads_file" "${response_file:-}"' EXIT

echo "Registering test user..."
register_payload="$(make_json register "$SEED_USERNAME" "$SEED_EMAIL" "$SEED_DISPLAY_NAME" "$SEED_PASSWORD")"
token=""

if register_status="$(
    curl -sS -X POST "$REGISTER_URL" \
        -H "Content-Type: application/json" \
        --data-binary "$register_payload" \
        --max-time 15 \
        -o "$register_response" \
        -w "%{http_code}"
)"; then
    if [[ "$register_status" == 2* ]]; then
        token="$(json_field token < "$register_response")"
        echo "Test user registered!"
    elif grep -qi "sudah terdaftar" "$register_response"; then
        echo "Test user already exists. Proceeding to login..."
    else
        echo "Gagal register test user." >&2
        echo "Status Code: $register_status" >&2
        echo "Response Body: $(<"$register_response")" >&2
        exit 1
    fi
else
    echo "Gagal register test user: curl request failed" >&2
    exit 1
fi

if [[ -z "$token" ]]; then
    echo "Logging in..."
    login_payload="$(make_json login "$SEED_EMAIL" "$SEED_PASSWORD")"

    if login_status="$(
        curl -sS -X POST "$AUTH_URL" \
            -H "Content-Type: application/json" \
            --data-binary "$login_payload" \
            --max-time 15 \
            -o "$login_response" \
            -w "%{http_code}"
    )"; then
        if [[ "$login_status" == 2* ]]; then
            token="$(json_field token < "$login_response")"
            echo "Login berhasil, token didapatkan!"
        else
            echo "Gagal login. Pastikan Auth Service berjalan dan password seed user belum diubah." >&2
            echo "Status Code: $login_status" >&2
            echo "Response Body: $(<"$login_response")" >&2
            exit 1
        fi
    else
        echo "Gagal login: curl request failed" >&2
        exit 1
    fi
else
    echo "Token didapatkan dari register response!"
fi

echo "Fetching existing bacaan..."
if ! status="$(curl -sS -X GET "$BACAAN_URL" -H "Authorization: Bearer $token" --max-time 15 -o "$bacaan_file" -w "%{http_code}")"; then
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
    comments = [
        {
            "bacaanId": bacaan_id,
            "commentContent": "Artikel yang sangat informatif dan membuka wawasan!",
            "parentComment": None,
        },
        {
            "bacaanId": bacaan_id,
            "commentContent": "Saya suka dengan gaya penulisannya. Sangat mudah dipahami.",
            "parentComment": None,
        },
        {
            "bacaanId": bacaan_id,
            "commentContent": "Apakah ada referensi lebih lanjut untuk topik ini?",
            "parentComment": None,
        },
    ]

    for payload in comments:
        print(json.dumps({"title": title, "payload": payload}, ensure_ascii=False))
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
        echo "Menambahkan komentar untuk bacaan: $title"
        current_title="$title"
    fi

    response_file="$(mktemp)"
    if status="$(
        curl -sS -X POST "$FORUM_URL" \
            -H "Authorization: Bearer $token" \
            -H "Content-Type: application/json; charset=utf-8" \
            --data-binary "$payload" \
            --max-time 15 \
            -o "$response_file" \
            -w "%{http_code}"
    )"; then
        if [[ "$status" == 2* ]]; then
            success=$((success + 1))
        else
            echo "[FAIL] Gagal menambahkan komentar: HTTP $status $(<"$response_file")"
            failed=$((failed + 1))
        fi
    else
        echo "[FAIL] Gagal menambahkan komentar: curl request failed"
        failed=$((failed + 1))
    fi

    rm -f "$response_file"
done < "$payloads_file"

echo
echo "=== Seeding Komentar Complete ==="
echo "Success: $success | Failed: $failed"
