#!/usr/bin/env bash
#
# Extract coverage from Swift test run and generate badge JSON + report.
# Usage: ./scripts/coverage.sh [--badge-only]

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BADGE_ONLY="${1:-}"
BADGE_FILE="$ROOT_DIR/coverage-badge.json"
REPORT_FILE="$ROOT_DIR/.build/artifacts/coverage-report.txt"

mkdir -p .build/artifacts

BIN_PATH=$(swift build --show-bin-path 2>/dev/null)
PROFDATA=$(find .build -name 'default.profdata' -type f 2>/dev/null | head -1)

if [ -z "$PROFDATA" ]; then
    echo "No profdata found. Run 'make test' first."
    exit 1
fi

EXEC=$(find "$BIN_PATH" -name "*.xctest" -o -name "PrismPackageTests" 2>/dev/null | head -1)

if [ -z "$EXEC" ]; then
    echo "No test executable found."
    exit 1
fi

if [ -d "$EXEC" ]; then
    EXEC="$EXEC/Contents/MacOS/$(basename "${EXEC%.xctest}")"
fi

REPORT=$(xcrun llvm-cov report "$EXEC" \
    --instr-profile="$PROFDATA" \
    --ignore-filename-regex='.build|Tests' 2>/dev/null || echo "")

if [ -z "$REPORT" ]; then
    echo "Could not generate coverage report."
    exit 1
fi

TOTAL=$(echo "$REPORT" | grep '^TOTAL' | awk '{print $NF}' | tr -d '%')

if [ -z "$TOTAL" ]; then
    echo "Could not extract coverage percentage."
    exit 1
fi

# Color logic
if (( $(echo "$TOTAL >= 90" | bc -l) )); then
    COLOR="brightgreen"
elif (( $(echo "$TOTAL >= 80" | bc -l) )); then
    COLOR="green"
elif (( $(echo "$TOTAL >= 60" | bc -l) )); then
    COLOR="yellow"
elif (( $(echo "$TOTAL >= 40" | bc -l) )); then
    COLOR="orange"
else
    COLOR="red"
fi

# Generate shields.io endpoint JSON
cat > "$BADGE_FILE" <<EOF
{
  "schemaVersion": 1,
  "label": "coverage",
  "message": "${TOTAL}%",
  "color": "${COLOR}",
  "style": "flat-square"
}
EOF

echo "Badge: coverage-badge.json → ${TOTAL}% (${COLOR})"

if [ "$BADGE_ONLY" = "--badge-only" ]; then
    exit 0
fi

# Full report
echo "$REPORT" > "$REPORT_FILE"

# Per-module summary
echo ""
echo "── Per-Module Coverage ──────────────────────────"
echo "$REPORT" | grep -E '^Sources/Prism[^/]+/' | \
    awk '{
        split($1, parts, "/");
        module = parts[2];
        covered += $4;
        total += $6;
    }
    END {
        for (m in covered) {
            if (total[m] > 0) {
                pct = (covered[m] / total[m]) * 100;
                printf "  %-30s %6.1f%%\n", m, pct;
            }
        }
    }' 2>/dev/null || true

echo ""
echo "  TOTAL                          ${TOTAL}%"
echo ""
echo "Full report: .build/artifacts/coverage-report.txt"
