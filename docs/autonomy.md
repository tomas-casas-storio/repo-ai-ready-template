# Autonomy, risk tiers and human checkpoints

Default mode: **spec-gated, low-risk PRs auto-merge.**
A human approves the spec in Jira. After that, the agent implements, validates and, for low-risk
changes, merges without further human action. Anything else goes to a human.

## Flow

```
Jira spec approved ──► agent branch + PR ──► make verify (CI)
                                               │ fail ──► agent fixes (max 2 rounds) ──► needs-human
                                               ▼ pass
                                guard-tests · secrets-scan · spec-gate · risk-gate
                                               │
                         low risk ─────────────┴───────────── high risk
                             │                                    │
                     auto-merge (squash)          CODEOWNER / human approval on head commit
                                                                  │
                                                              auto-merge
```

## How the tier is decided

Computed by `scripts/risk-tier.sh`, never declared by the agent:

| Signal                                                        | Tier |
| ------------------------------------------------------------- | ---- |
| Any path in `.github/risk/high-risk-paths` changed            | high |
| More than 400 changed lines or 20 files                       | high |
| Label `risk:high` or `needs-human` (a human or CI can add it) | high |
| Otherwise                                                     | low  |

Labels can only **raise** the tier. Changing the thresholds or the path list is itself a high-risk change.

## Where each control is enforced

| Control                                 | Enforced by                                                                         | Not by            |
| --------------------------------------- | ----------------------------------------------------------------------------------- | ----------------- |
| No direct push to `main`, no force-push | Ruleset `protect-default-branch`                                                    | AGENTS.md         |
| Required checks pass                    | Ruleset required status checks                                                      | Agent self-report |
| Human review of high-risk paths         | CODEOWNERS + `require_code_owner_review`                                            | —                 |
| Human review of large diffs             | `risk-gate` job                                                                     | —                 |
| Agent can't approve its own PR          | GitHub (authors can't approve their own PRs) + separate agent identity              | —                 |
| Agent can't weaken controls             | GitHub App token without `workflows`/admin permission; controls paths are high risk | —                 |
| Tests not removed or skipped            | `guard-tests` job + ESLint rule                                                     | —                 |
| Fix-loop limit (2 rounds)               | `loop-limit` job (labels `needs-human`, disables auto-merge)                        | —                 |
| Spec approved                           | `spec-gate` job (Jira status, fails closed)                                         | —                 |

## Agent identity (set up once, by a human admin)

1. Create a dedicated GitHub App for the agent with **Contents: write**, **Pull requests: write**,
   **Issues: write** and nothing else. No `Workflows`, `Administration`, `Secrets` or `Environments`.
2. Do not add it to any ruleset bypass list or to CODEOWNERS.
3. Give the agent runtime only that App's token and a read-only Jira token. No cloud or production credentials.
4. Set the repo's default `GITHUB_TOKEN` permissions to read-only.
5. Run `scripts/apply-rulesets.sh`, then `make verify-controls`, and record the output in `docs/readiness.md`.

## Moving checkpoints (progression)

Change checkpoints for a **task type**, based on evidence, never because of a single run:

| Step  | Change                                                                  | Evidence needed                                                                   |
| ----- | ----------------------------------------------------------------------- | --------------------------------------------------------------------------------- |
| Now   | Low-risk auto-merge; high risk is human-reviewed                        | Controls verified                                                                 |
| Next  | Move a path out of `high-risk-paths` (for example a well-tested module) | N consecutive merged PRs on that path with 0 reverts and 0 post-merge regressions |
| Next  | Auto-deploy merged low-risk changes to non-prod with smoke tests        | Deploy pipeline + rollback verified                                               |
| Later | Prod release for low-risk task types                                    | Agreed with release owner; ADR records the conditions                             |

Record each change as an ADR in `docs/decisions/` with "Revisit when". If reverts or regressions rise,
restore the checkpoint.
