# 0001: Agent-ready baseline for this template

Status: proposed
Owner: TODO
Date: 2026-11-19
Reason and relevant trade-off:

- **Single gate `make verify`**: one command for people, CI and agents. Stack commands live only in
  the Makefile, so the template stays stack-agnostic. TypeScript/Node (pnpm, ESLint, tsc, Vitest)
  is the wired reference example.
- **Tool-agnostic agents**: limits are enforced on GitHub (ruleset, CODEOWNERS, required checks, App
  token scopes), not in any one agent's config file. `AGENTS.md` is guidance only.
- **Spec-gated autonomy with low-risk auto-merge**: human approval moves to the Jira spec. Risk tier
  is computed from paths and diff size. Labels can only raise it. Trade-off: faster flow for
  routine work, with human review kept for controls, dependencies and large changes.
- **Fix-loop limit of 2 rounds**, then hand off to a human.

Affected repositories or tasks: repositories created from this template.
Revisit when: after the first 10 agent PRs, review reverts, interventions and tier thresholds.
