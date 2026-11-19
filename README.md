# repo-ai-ready-template

Template for **agent-first repositories**: AI agents build, test and merge routine changes with minimal
human interaction. People define outcomes (Jira specs), set boundaries, and handle exceptions.

## Quick start

```bash
make setup     # install pinned deps (or open in the devcontainer)
make verify    # the gate: format, lint, types, tests+coverage, build
make help      # all targets
```

## What's in the box

| Capability          | Files                                                                                                                              |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| Understand the work | `AGENTS.md`, `docs/context/index.md`, `docs/decisions/`, `docs/task-spec-template.md`                                              |
| Run the work        | `Makefile`, `.devcontainer/`, `.nvmrc`, `pnpm-lock.yaml`, `.env.example`                                                           |
| Verify the work     | `make verify`, `scripts/guard-tests.sh`, `.github/workflows/verify.yml`, `security.yml`                                            |
| Control the work    | `.github/rulesets/main.json`, `.github/CODEOWNERS`, `.github/risk/high-risk-paths`, `governance.yml`, `scripts/verify-controls.sh` |
| Operate and improve | `.github/pull_request_template.md` (validation summary), `docs/runbook.md`, `docs/readiness.md`                                    |

How autonomy, risk tiers and enforcement fit together: [docs/autonomy.md](docs/autonomy.md).

## Adopting this template (one-time, human admin)

1. Replace `TODO`s in `AGENTS.md`, `CODEOWNERS`, and `docs/context/index.md`.
2. Swap the reference stack: change `src/`, the Makefile targets and `security.yml` CodeQL language. Keep the target names.
3. Set repo variables `JIRA_BASE_URL` and `JIRA_APPROVED_STATUSES`, and secrets `JIRA_USER` and `JIRA_API_TOKEN`.
4. Create the labels `needs-human`, `risk:high`, `risk:low`, `risk:computed-high` and `tests-removed-approved`.
5. Create the agent's GitHub App identity (see [docs/autonomy.md](docs/autonomy.md#agent-identity-set-up-once-by-a-human-admin)).
6. Run `scripts/apply-rulesets.sh`, then `make verify-controls`. Record the results in `docs/readiness.md`.
