# equiv communication protocol

All runtime communication lives under `<repo>/.equiv/`.

The CEO owns persistence. Technical departments return structured content; the CEO writes it without changing technical meaning.

## `.equiv/state.md`

Keep only current project facts that are useful across tasks.

```md
# Project state

## Goal
-

## Current architecture
-

## Current implementation
-

## Known current issues
-

## Last verified
-
```

Do not keep a chronological transcript here. Replace stale facts rather than appending history.

## `.equiv/invariants.md`

Long-lived constraints that Engineering and Audit should preserve.

```md
# Invariants

- INV-001: ...
```

Only record an invariant when it is grounded in the user's explicit requirement, project documentation, or independently verified implementation contract.

## `.equiv/active/brief.md`

The CEO writes this from the user's request.

```md
# Task brief

## Request
<user request, preserved faithfully>

## Constraints
- <explicit constraints only>

## Acceptance
- <explicit acceptance criteria, if any>

## Non-goals
- <only when explicitly supplied or agreed>
```

The CEO must not add a proposed implementation.

## `.equiv/active/engineer.md`

```md
# Engineering

## Position
- decision: implement | no-change | blocked
- summary: ...

## Evidence
- path/to/file:line — ...

## Proposed change
- ...

## Delegations
- helper: equiv-engineer-assistant | equiv-engineer-implementer
  task: ...
  result: ...

## Implementation
- changed: ...
- validation: ...
- residual-risk: ...

## Issue responses
- I-001: accept | disagree | uncertain — ...
```

Engineering owns the technical content.

## `.equiv/active/observer.md`

```md
# Audit

## Independent position
- ...

## Evidence
- path/to/file:line — ...

## Verdict
APPROVE | FINDINGS | BLOCKED

## Findings
- I-001: ...

## Residual risk
- ...
```

`APPROVE` should be compact. Audit must not invent findings merely to demonstrate independence.

## `.equiv/active/issues.md`

Use one entry per material dispute.

```md
# Issue ledger

## I-001
status: open | resolved | disputed | withdrawn
severity: blocker | major | minor
claim: <single concrete claim>
evidence:
- path/to/file:line — <evidence>
observer: change-required | concern | withdrawn
engineer: pending | accept | disagree | uncertain
engineer-reason: <reason or ->
observer-final: pending | resolved | still-disputed | withdrawn
next: <one bounded next action or ->
```

Do not paste transcripts. Keep one issue focused on one claim.

## `.equiv/active/result.md`

```md
# Result

## Request
- ...

## Engineering result
- ...

## Audit verdict
- ...

## Validation
- ...

## Changed files
- ...

## Unresolved issues
- none
```

If unresolved issues exist, include both department positions and their evidence. The CEO must not add a technical tie-breaker.
