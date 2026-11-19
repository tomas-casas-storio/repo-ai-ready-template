# Operate and recover

## Detect

- CI failures on `main` (`verify` runs on push).
- Post-merge regressions: TODO link to monitoring/alerts for this service.
- Weekly: review PRs labelled `needs-human` or `risk:computed-high` and the "Human interventions" field.

## Recover

1. Revert the squash commit: `gh pr revert <PR>`, or `git revert <sha>` on a branch and open a PR.
   Reverts follow the same gate. A human may approve to speed it up.
2. Add label `risk:high` to the related Jira task type or path until the root cause is fixed.
3. If a control failed, open an issue and treat it as an incident.

## Improve (after every intervention)

For each human intervention, fix the cause in the right place:

| Cause                            | Fix in                                                |
| -------------------------------- | ----------------------------------------------------- |
| Agent misunderstood intent       | Jira spec template / acceptance criteria              |
| Agent broke an undocumented rule | AGENTS.md "Rules you cannot discover" (keep it short) |
| Bug got past the gate            | Add a test or check                                   |
| Setup or command failed          | `make setup` / devcontainer                           |
