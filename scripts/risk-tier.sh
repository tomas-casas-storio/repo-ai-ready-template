#!/usr/bin/env bash
# Prints the risk tier of the diff vs BASE: "low" or "high", plus reasons on stderr.
# Tier is computed, never declared: labels can only RAISE it (see risk-gate workflow).
#   high if any changed path matches .github/risk/high-risk-paths
#   high if diff exceeds MAX_LOW_RISK_LINES or MAX_LOW_RISK_FILES
set -euo pipefail

BASE="${1:-origin/main}"
PATTERNS_FILE="${PATTERNS_FILE:-.github/risk/high-risk-paths}"
MAX_LOW_RISK_LINES="${MAX_LOW_RISK_LINES:-400}"
MAX_LOW_RISK_FILES="${MAX_LOW_RISK_FILES:-20}"

merge_base="$(git merge-base "$BASE" HEAD)"
files="$(git diff --name-only "$merge_base" HEAD)"
patterns="$(grep -vE '^[[:space:]]*(#|$)' "$PATTERNS_FILE")"
file_count="$(grep -c . <<< "$files" || true)"

tier=low
while IFS= read -r f; do
  [[ -z "$f" ]] && continue
  while IFS= read -r p; do
    # shellcheck disable=SC2053 # glob match intended; '*' also matches '/'
    if [[ "$f" == $p ]]; then
      echo "high-risk path: $f (matches $p)" >&2
      tier=high
    fi
  done <<< "$patterns"
done <<< "$files"

# Generated lockfiles don't count toward size (they are still high risk via the path list).
lines="$(git diff --numstat "$merge_base" HEAD -- . ':!pnpm-lock.yaml' ':!package-lock.json' ':!yarn.lock' | awk '{a+=$1; d+=$2} END {print a+d+0}')"
if (( lines > MAX_LOW_RISK_LINES )); then
  echo "diff too large: $lines lines > $MAX_LOW_RISK_LINES" >&2; tier=high
fi
if (( file_count > MAX_LOW_RISK_FILES )); then
  echo "too many files: $file_count > $MAX_LOW_RISK_FILES" >&2; tier=high
fi

echo "$tier"
