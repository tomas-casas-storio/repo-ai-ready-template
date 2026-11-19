#!/usr/bin/env bash
# Spec gate (AI SDLC Golden Path): every PR must reference a Jira ticket, and the
# ticket's Decision/Verification spec must be approved before the PR can merge.
#
# Inputs (env):
#   PR_TITLE, PR_BRANCH          — searched for a Jira key (e.g. ABC-123)
#   JIRA_BASE_URL                — e.g. https://<org>.atlassian.net
#   JIRA_USER, JIRA_API_TOKEN    — read-only service account (repo secrets)
#   JIRA_APPROVED_STATUSES       — comma list, default "Spec Approved,In Progress"
#
# Outputs: writes jira_key and spec_approved=true|false to $GITHUB_OUTPUT if set.
# Fails closed: no key, no Jira config, or unapproved spec => exit 1.
set -euo pipefail

APPROVED="${JIRA_APPROVED_STATUSES:-Spec Approved,In Progress}"
out() { [[ -n "${GITHUB_OUTPUT:-}" ]] && echo "$1" >> "$GITHUB_OUTPUT"; true; }

key="$(printf '%s %s' "${PR_TITLE:-}" "${PR_BRANCH:-}" | grep -oE '\b[A-Z][A-Z0-9]+-[0-9]+\b' | head -1 || true)"
if [[ -z "$key" ]]; then
  echo "::error::No Jira key found in PR title or branch (expected e.g. ABC-123)."
  out "spec_approved=false"; exit 1
fi
out "jira_key=$key"
echo "Jira key: $key"

if [[ -z "${JIRA_BASE_URL:-}" || -z "${JIRA_API_TOKEN:-}" ]]; then
  echo "::error::Jira not configured (JIRA_BASE_URL / JIRA_API_TOKEN). Spec approval cannot be verified."
  out "spec_approved=false"; exit 1
fi

status="$(curl -fsS -u "${JIRA_USER}:${JIRA_API_TOKEN}" \
  "${JIRA_BASE_URL%/}/rest/api/3/issue/${key}?fields=status" \
  | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>console.log(JSON.parse(s).fields.status.name))')"
echo "Jira status: $status"

IFS=',' read -ra ok <<< "$APPROVED"
for s in "${ok[@]}"; do
  if [[ "$status" == "$s" ]]; then out "spec_approved=true"; exit 0; fi
done
echo "::error::Spec for $key is not approved (status '$status'; approved: $APPROVED)."
out "spec_approved=false"; exit 1
