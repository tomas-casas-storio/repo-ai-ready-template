# Agent guide: <repository>

Purpose and boundaries: [README.md](README.md) <!-- TODO: one line on what this repo owns and does not own -->
Setup: `make setup`
Verify gate (format, lint, types, tests+coverage, build): `make verify` — the same command CI runs.
Known baseline issues: none

## How work arrives

Work starts from a Jira ticket whose Decision / Verification spec is approved.
Do not start, or ask for the spec to be approved, if the ticket is not in an approved status.
Branch `<JIRA-KEY>-short-desc`, PR title `<JIRA-KEY>: summary`. The `spec-gate` check enforces this.

## Rules you cannot discover from the code

- Every acceptance criterion maps to a named test (`AC1: ...`). Add the test before or with the change.
- Never delete tests, lower coverage thresholds or add `.skip`/`.only`. CI blocks it (`guard-tests`).
- Never edit `.github/`, `scripts/`, `Makefile`, gate configs or this file unless the ticket asks for it.
  Those paths are high risk: they need human review and are never auto-merged.
- Keep PRs small (≤ 400 changed lines, ≤ 20 files) so they stay low risk. Split larger work.
- If the spec is missing, ambiguous or contradicts the code: stop, comment on the Jira ticket, and
  do not invent business rules. A proposed decision is not an approved one.
- Fix-loop limit: if `make verify` still fails after 2 fix rounds, stop and summarise the blockers
  in the PR. CI applies `needs-human` and disables auto-merge.

## Relevant context

- Shared engineering context: <!-- TODO: shared index repo URL or mounted path --> see [docs/context/index.md](docs/context/index.md)
- Applicable standards: <!-- TODO: entries in the shared index -->
- Contracts: <!-- TODO: authoritative domain contract links -->
- Repository decisions: [docs/decisions/](docs/decisions/)
- Autonomy and risk tiers: [docs/autonomy.md](docs/autonomy.md)

Access to linked sources: <!-- TODO: Jira/Confluence connector or versioned snapshot the agent can read -->

## Execution limits

Permitted: edit files on a feature branch, run `make` targets, open/update PRs, comment on the Jira ticket.
Not permitted: push to `main`, approve or merge PRs yourself, change repo settings, access production
credentials or data, or edit workflows.
Enforced through: GitHub ruleset (`.github/rulesets/main.json`), CODEOWNERS, required checks, and the
agent's GitHub App token scopes. Verify with `make verify-controls`.

## Reporting

Fill in the validation summary in the PR template: changes, AC → evidence, checks, limitations,
assumptions and human interventions.
