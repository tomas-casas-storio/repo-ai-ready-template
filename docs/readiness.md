# Readiness checklist

Record each item as **met / gap / n/a** with a link to evidence. For each gap, name an owner and a
next action, and say whether it blocks execution. Reassess after each run.
Readiness applies to the assessed scope of work, not every possible change.

| #   | Check                                                           | How to prove it                                                        | Status | Evidence                       |
| --- | --------------------------------------------------------------- | ---------------------------------------------------------------------- | ------ | ------------------------------ |
| 1   | Agent can read the task spec and acceptance criteria            | Agent fetches the Jira ticket through its configured connector         | gap    |                                |
| 2   | Agent can follow one AGENTS.md link to the authoritative source | Agent retrieves a shared-index entry's content, not just the link      | gap    |                                |
| 3   | Clean-clone setup works in the agent environment                | `git clone && make setup && make verify` in the devcontainer/runner    | met    | local run                      |
| 4   | Gate is the same for people, CI and agent                       | `verify.yml` runs `make verify`                                        | met    | `.github/workflows/verify.yml` |
| 5   | Validation detects incorrect implementations                    | Mutate a mapping in `src/`, confirm `make verify` fails                |        |                                |
| 6   | Gate is fast and stable                                         | Runtime < 5 min; 3 re-runs on an unchanged commit give the same result |        |                                |
| 7   | Removing or skipping a test is caught                           | PR deleting a test fails `guard-tests`                                 |        |                                |
| 8   | Execution limits are enforced                                   | `make verify-controls` passes; agent push to `main` is rejected        | gap    |                                |
| 9   | Spec gate fails closed                                          | PR without a Jira key, or with an unapproved spec, fails `spec-gate`   |        |                                |
| 10  | Risk gate routes correctly                                      | PR touching `.github/` is not auto-merged without approval             |        |                                |
| 11  | Outcomes are reviewable and interventions are recorded          | PR template validation summary completed                               |        |                                |
| 12  | Recovery path exists                                            | Revert of a merged PR rehearsed (see `docs/runbook.md`)                |        |                                |
