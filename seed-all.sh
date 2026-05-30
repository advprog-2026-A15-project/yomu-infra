#!/bin/bash
# seed-all.sh - Run all seed scripts in the correct order

set -e

echo "=========================================="
echo "       Yomu App - Data Seeding"
echo "=========================================="

SCRIPTS=(
    "seed-liga.sh"
    "seed-bacaan.sh"
    "seed-kuis.sh"
    "seed-komentar.sh"
)

for SCRIPT in "${SCRIPTS[@]}"; do
    if [ -f "./$SCRIPT" ]; then
        echo ""
        echo ">>> Running $SCRIPT..."
        bash "./$SCRIPT"
    else
        echo ""
        echo ">>> Warning: $SCRIPT not found. Skipping."
    fi
done

echo ""
echo "=========================================="
echo "    All Data Seeding Scripts Completed!"
echo "=========================================="
