# Jira task spec template (Decision / Verification)

Paste into the Jira ticket. The agent works only from this. A human moves the ticket to an approved
status (default `Spec Approved`) to authorise the work. That status is what `spec-gate` checks.

```
Outcome:          <one sentence: what is true when done>
Scope:            <what changes, where>
Out of scope:     <explicitly excluded>
Context:          <links: specs, contracts, shared-index entries, ADRs>
Acceptance criteria (each becomes a named test):
  AC1: <given/when/then>
  AC2: <existing behaviour preserved>
  AC3: <invalid input rejected with expected error>
Endpoint:         <merged to main | validated in <non-prod env> | production>
Risk notes:       <anything that should force human review; add label risk:high>
Owner for questions: <person>
```
