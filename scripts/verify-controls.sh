#!/usr/bin/env bash
# Proves the execution controls are ENFORCED on GitHub, not just documented.
# A template file alone does not enforce permissions — this script checks the live repo.
# Read-only. Exit 1 if any control is missing. Record the output as readiness evidence.
set -uo pipefail
repo="${REPO:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"
branch="${DEFAULT_BRANCH:-main}"
fail=0
pass() { echo "PASS  $1"; }
miss() { echo "FAIL  $1"; fail=1; }

rules="$(gh api "repos/$repo/rules/branches/$branch" 2>/dev/null || echo '[]')"
has_rule() { echo "$rules" | node -e "let s='';process.stdin.on('data',d=>s+=d).on('end',()=>process.exit(JSON.parse(s).some(r=>r.type==='$1')?0:1))"; }

has_rule pull_request        && pass "PR required to change $branch"            || miss "PR not required on $branch"
has_rule non_fast_forward    && pass "force-push blocked on $branch"            || miss "force-push allowed on $branch"
has_rule deletion            && pass "deletion blocked on $branch"              || miss "deletion allowed on $branch"
has_rule required_status_checks && pass "required status checks on $branch"   || miss "no required status checks on $branch"

required="$(echo "$rules" | node -e "let s='';process.stdin.on('data',d=>s+=d).on('end',()=>{const r=JSON.parse(s).filter(r=>r.type==='required_status_checks').flatMap(r=>r.parameters.required_status_checks.map(c=>c.context));console.log(r.join('\n'))})")"
for check in verify guard-tests spec-gate risk-gate secrets-scan; do
  grep -qx "$check" <<< "$required" && pass "required check: $check" || miss "check not required: $check"
done

echo "$rules" | node -e "let s='';process.stdin.on('data',d=>s+=d).on('end',()=>process.exit(JSON.parse(s).some(r=>r.type==='pull_request'&&r.parameters.require_code_owner_review)?0:1))" \
  && pass "code-owner review required" || miss "code-owner review not required"

errors="$(gh api "repos/$repo/codeowners/errors" -q '.errors | length' 2>/dev/null || echo 1)"
[[ "$errors" == "0" ]] && pass "CODEOWNERS valid" || miss "CODEOWNERS missing or invalid"

auto="$(gh api "repos/$repo" -q .allow_auto_merge 2>/dev/null)"
[[ "$auto" == "true" ]] && pass "auto-merge enabled (gated by required checks)" || miss "auto-merge disabled"

perm="$(gh api "repos/$repo/actions/permissions/workflow" -q .default_workflow_permissions 2>/dev/null)"
[[ "$perm" == "read" ]] && pass "default GITHUB_TOKEN is read-only" || miss "default GITHUB_TOKEN is '$perm' (want read)"

echo
echo "Manual checks (record evidence in docs/readiness.md):"
echo "  - Agent identity is NOT in any ruleset bypass list and NOT a CODEOWNER."
echo "  - Agent token lacks: admin, 'workflows' permission, production secrets/environments."
echo "  - From the agent's environment: 'git push origin HEAD:$branch' is rejected."
exit "$fail"
