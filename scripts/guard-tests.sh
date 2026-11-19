#!/usr/bin/env bash
# Fails if a change weakens the test suite relative to BASE:
#   1. deletes or renames away a test file
#   2. reduces the number of test cases
#   3. adds skip/only/todo markers
# Stack-agnostic: adjust TEST_FILE_REGEX / CASE_REGEX / SKIP_REGEX for your language.
# Legitimate removals need a human: apply the `tests-removed-approved` label (CODEOWNER only).
set -euo pipefail

BASE="${1:-origin/main}"
TEST_FILE_REGEX="${TEST_FILE_REGEX:-(\.test|\.spec)\.[cm]?[jt]sx?$|_test\.(go|py)$|^tests?/}"
# POSIX ERE only (git grep and BSD grep don't support \s or \b).
CASE_REGEX="${CASE_REGEX:-^[[:space:]]*(it|test)[[:space:]]*\(}"
SKIP_REGEX="${SKIP_REGEX:-(^|[^[:alnum:]_])((it|test|describe)\.(skip|only|todo)|x(it|describe)[[:space:]]*\(|@pytest\.mark\.skip|t\.Skip\()}"

merge_base="$(git merge-base "$BASE" HEAD)"
fail=0

deleted="$(git diff --name-only --diff-filter=D "$merge_base" HEAD | grep -E "$TEST_FILE_REGEX" || true)"
if [[ -n "$deleted" ]]; then
  echo "::error::Test files deleted:"; echo "$deleted"; fail=1
fi

count_cases() { # $1 = git rev
  { git grep -hE "$CASE_REGEX" "$1" -- . 2>/dev/null || true; } | wc -l | tr -d ' '
}
before="$(count_cases "$merge_base")"
after="$(count_cases HEAD)"
echo "Test cases: base=$before head=$after"
if (( after < before )); then
  echo "::error::Number of test cases decreased ($before -> $after)"; fail=1
fi

added_skips="$(git diff -U0 "$merge_base" HEAD -- . ':!scripts/guard-tests.sh' ':!eslint.config.*' | grep -E '^\+[^+]' | grep -E "$SKIP_REGEX" || true)"
if [[ -n "$added_skips" ]]; then
  echo "::error::Skip/only markers added:"; echo "$added_skips"; fail=1
fi

if (( fail )); then
  echo "Test suite weakened. If intentional, a CODEOWNER must apply label 'tests-removed-approved'."
fi
exit "$fail"
