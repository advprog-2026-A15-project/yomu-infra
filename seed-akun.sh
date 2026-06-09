#!/bin/bash
# seed-akun.sh — Inject multiple dummy accounts into service-auth for profiling purposes
# Run: chmod +x seed-akun.sh && ./seed-akun.sh

REGISTER_URL=${REGISTER_URL:-http://localhost:8081/api/auth/register}
TOTAL_ACCOUNTS=50 # Ubah jumlah ini sesuai kebutuhan load test/profiling Anda

echo -e "\e[36m==========================================\e[0m"
echo -e "\e[36m   Yomu App - Profiling Account Seeder\e[0m"
echo -e "\e[36m==========================================\e[0m"
echo -e "\e[33mMulai melakukan pendaftaran (registrasi) $TOTAL_ACCOUNTS akun...\e[0m"

SUCCESS=0
FAILED=0

for i in $(seq 1 $TOTAL_ACCOUNTS); do
    USERNAME="testuser${i}"
    EMAIL="testuser${i}@yomu.local"
    DISPLAYNAME="Test User ${i}"
    PASSWORD="password123"

    PAYLOAD=$(cat <<EOF
{
    "username": "${USERNAME}",
    "email": "${EMAIL}",
    "displayName": "${DISPLAYNAME}",
    "password": "${PASSWORD}"
}
EOF
)

    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST $REGISTER_URL \
        -H "Content-Type: application/json" \
        -d "$PAYLOAD")

    if [ "$HTTP_STATUS" -eq 200 ] || [ "$HTTP_STATUS" -eq 201 ]; then
        echo -e "\e[32m[OK] Berhasil register: $USERNAME\e[0m"
        ((SUCCESS++))
    elif [ "$HTTP_STATUS" -eq 400 ]; then
        echo -e "\e[90m[SKIP] Akun sudah terdaftar: $USERNAME\e[0m"
    else
        echo -e "\e[31m[FAIL] Gagal register $USERNAME (HTTP Status: $HTTP_STATUS)\e[0m"
        ((FAILED++))
    fi
done

echo -e "\n\e[36m=== Seeding Akun Selesai ===\e[0m"
echo "Success: $SUCCESS | Failed: $FAILED"
