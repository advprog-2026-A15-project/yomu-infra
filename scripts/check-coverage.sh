#!/usr/bin/env bash
# Run tests + generate JaCoCo coverage report for each backend service.
#
# Usage:
#   ./scripts/check-coverage.sh                           # all services
#   ./scripts/check-coverage.sh service-auth service-forum  # specific services
#   SKIP_TESTS=true ./scripts/check-coverage.sh           # parse existing reports only
#   OPEN_REPORTS=true ./scripts/check-coverage.sh         # open HTML in browser after

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"

SKIP_TESTS="${SKIP_TESTS:-false}"
OPEN_REPORTS="${OPEN_REPORTS:-false}"

# Default services; override by passing args
if [ "$#" -gt 0 ]; then
    SERVICES=("$@")
else
    SERVICES=(
        "service-auth"
        "service-learning"
        "service-achievements"
        "service-forum"
        "service-clan"
        "service-notification"
        "api-gateway"
        "shared-lib"
    )
fi

CYAN="\033[36m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

echo ""
echo -e "${CYAN}======================================================"
echo "  YOMU - JaCoCo Coverage Check"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo -e "======================================================${RESET}"
echo ""

declare -A RESULTS_STATUS
declare -A RESULTS_INSTRUCTION
declare -A RESULTS_BRANCH
declare -A RESULTS_REPORT

parse_pct() {
    local xml_path="$1"
    local type="$2"
    # Extract covered and missed for the given counter type at report level
    # JaCoCo XML: <report><counter type="INSTRUCTION" missed="X" covered="Y"/>
    python3 - "$xml_path" "$type" << 'PYEOF'
import sys, xml.etree.ElementTree as ET
path, ctype = sys.argv[1], sys.argv[2]
try:
    tree = ET.parse(path)
    root = tree.getroot()
    for counter in root.findall('counter'):
        if counter.get('type') == ctype:
            cov  = int(counter.get('covered', 0))
            miss = int(counter.get('missed', 0))
            tot  = cov + miss
            if tot == 0:
                print("N/A (no data)")
            else:
                pct = round(cov / tot * 100, 1)
                print(f"{pct}% ({cov}/{tot})")
            sys.exit(0)
    print("N/A")
except Exception as e:
    print(f"ERROR: {e}")
PYEOF
}

for service in "${SERVICES[@]}"; do
    SERVICE_DIR="$ROOT/$service"

    if [ ! -d "$SERVICE_DIR" ]; then
        echo -e "${YELLOW}[$service] SKIP — directory not found${RESET}"
        RESULTS_STATUS[$service]="NOT FOUND"
        RESULTS_INSTRUCTION[$service]="N/A"
        RESULTS_BRANCH[$service]="N/A"
        RESULTS_REPORT[$service]="N/A"
        continue
    fi

    if [ "$SKIP_TESTS" != "true" ]; then
        echo -e "${CYAN}[$service] Running tests...${RESET}"
        (
            cd "$SERVICE_DIR"
            chmod +x ./gradlew 2>/dev/null || true
            ./gradlew test jacocoTestReport --no-daemon
        )
        STATUS=$?
        if [ $STATUS -ne 0 ]; then
            echo -e "${RED}[$service] FAILED (exit $STATUS)${RESET}"
            RESULTS_STATUS[$service]="TEST FAILED"
            RESULTS_INSTRUCTION[$service]="N/A"
            RESULTS_BRANCH[$service]="N/A"
            RESULTS_REPORT[$service]="N/A"
            continue
        fi
        echo -e "${GREEN}[$service] Tests passed${RESET}"
    fi

    XML_PATH="$SERVICE_DIR/build/reports/jacoco/test/jacocoTestReport.xml"
    HTML_PATH="$SERVICE_DIR/build/reports/jacoco/test/html/index.html"

    if [ ! -f "$XML_PATH" ]; then
        echo -e "${YELLOW}[$service] WARNING — XML report not found${RESET}"
        RESULTS_STATUS[$service]="NO REPORT"
        RESULTS_INSTRUCTION[$service]="N/A"
        RESULTS_BRANCH[$service]="N/A"
        RESULTS_REPORT[$service]="N/A"
        continue
    fi

    INSTR=$(parse_pct "$XML_PATH" "INSTRUCTION")
    BRANCH=$(parse_pct "$XML_PATH" "BRANCH")

    # Color based on instruction coverage value
    PCT_VAL=$(echo "$INSTR" | grep -oP '^\d+\.\d+' || echo "0")
    if awk "BEGIN{exit !($PCT_VAL >= 80)}"; then
        COLOR=$GREEN
    elif awk "BEGIN{exit !($PCT_VAL >= 60)}"; then
        COLOR=$YELLOW
    else
        COLOR=$RED
    fi

    echo -e "${COLOR}[$service] Instruction: $INSTR  |  Branch: $BRANCH${RESET}"

    RESULTS_STATUS[$service]="OK"
    RESULTS_INSTRUCTION[$service]="$INSTR"
    RESULTS_BRANCH[$service]="$BRANCH"
    RESULTS_REPORT[$service]="$HTML_PATH"
done

echo ""
echo -e "${CYAN}======================================================"
echo "  SUMMARY"
echo -e "======================================================${RESET}"
printf "%-30s %-14s %-24s %-20s\n" "Service" "Status" "Instruction" "Branch"
printf "%-30s %-14s %-24s %-20s\n" "-------" "------" "-----------" "------"
for service in "${SERVICES[@]}"; do
    printf "%-30s %-14s %-24s %-20s\n" \
        "$service" \
        "${RESULTS_STATUS[$service]:-N/A}" \
        "${RESULTS_INSTRUCTION[$service]:-N/A}" \
        "${RESULTS_BRANCH[$service]:-N/A}"
done

echo ""
echo "HTML Reports:"
for service in "${SERVICES[@]}"; do
    report="${RESULTS_REPORT[$service]:-N/A}"
    if [ "$report" != "N/A" ] && [ -f "$report" ]; then
        echo "  $service: $report"
        if [ "$OPEN_REPORTS" = "true" ]; then
            xdg-open "$report" 2>/dev/null || open "$report" 2>/dev/null || true
        fi
    fi
done
echo ""
