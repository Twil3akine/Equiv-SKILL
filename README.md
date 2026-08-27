# equiv

**Engineering with an independent audit layer for Codex.**

`equiv` is a Codex Skill that turns the parent agent into a **CEO / control plane** instead of the primary engineer.
The parent receives the user's request, routes it to an Engineering department and an independent Audit department, relays their structured findings, and reports the resulting conclusion back to the user.

The parent agent is deliberately not allowed to become a third technical decision-maker.

```text
User (shareholder)
        │
        ▼
Main / CEO
  route & report only
        │
   ┌────┴───────────────┐
   ▼                    ▼
Engineering          Audit
Sol high             Terra high
   │                    │
   ├─ Implementer       ├─ Assistant
   │  Terra high        │  Luna medium
   │
   └─ Assistant
      Luna medium

Engineering  ← issues →  Audit
        │
        └── agreed result / unresolved issues
                     │
                     ▼
                  Main / CEO
                     │
                     ▼
                    User
```

## Why

A normal coding-agent session tends to concentrate several roles in one context: understanding requirements, designing the change, implementing it, reviewing it, and explaining the result. `equiv` separates those responsibilities.

- **Engineering** owns technical proposals and implementation decisions.
- **Audit** independently verifies assumptions, diffs, requirements, regressions, and unnecessary scope.
- **Main / CEO** owns routing and accountability to the user, not technical synthesis.
- Narrow assistants handle bounded searches and checks without accumulating long-lived context.

The goal is not to manufacture disagreement. Audit should approve correct work and object only when it has concrete evidence.

## Default model layout

| Role | Default | Responsibility |
| --- | --- | --- |
| Main / CEO | GPT-5.6 Sol, medium | User interface, routing, persistence, final report |
| `equiv-engineer-main` | GPT-5.6 Sol, high | Technical lead; proposal, decisions, responses to audit |
| `equiv-engineer-implementer` | GPT-5.6 Terra, high | Scoped code changes and validation |
| `equiv-engineer-assistant` | GPT-5.6 Luna, medium | Disposable bounded engineering investigations |
| `equiv-observer-main` | GPT-5.6 Terra, high | Independent technical audit |
| `equiv-observer-assistant` | GPT-5.6 Luna, medium | Disposable bounded evidence gathering |

The Skill cannot force the model used by the parent Codex session, so select Sol / medium for the main session if you want the default layout above.

`xhigh` is intentionally not the default. Raise the relevant agent configuration only when representative tasks show that the extra reasoning cost is useful.

## Runtime workspace

All inter-department working documents live under one hidden directory in the target repository:

```text
.equiv/
├── .gitignore
├── state.md
├── invariants.md
├── active/
│   ├── brief.md
│   ├── engineer.md
│   ├── observer.md
│   ├── issues.md
│   └── result.md
└── archive/
```

`.equiv/active/` is the only normal communication channel between departments. Previous tasks are archived and are **not** normal context.

The generated `.equiv/.gitignore` ignores runtime documents by default, so the working area does not pollute the project history. Remove or change it if you explicitly want to version these files.

## Token-control rules

`equiv` intentionally pays for independent Engineering and Audit reads, but avoids accidental duplication elsewhere.

1. **Project state is reused.** Stable facts go in `.equiv/state.md` and `.equiv/invariants.md` instead of being rediscovered from scratch on every turn.
2. **Audit is diff-first.** The observer starts from the request, Engineering report, changed files, and diff, then expands only where evidence is needed.
3. **Assistants are ephemeral.** One narrow question, one investigation, one concise result; do not keep assistants as long-lived conversational partners.
4. **Issue Ledger replaces transcript relay.** Departments exchange discrete claims, evidence, positions, and resolution state through `issues.md`, not full prose transcripts.
5. **Approval is short.** If Audit finds no actionable problem, it should return a compact approval rather than a ceremonial review essay.
6. **Debate is bounded.** Normally allow one Engineering response and one final Audit pass. Remaining material disagreement is reported to the user instead of creating an unbounded loop.
7. **Independent evidence is preserved.** Engineering and Audit may both read the same important code when independence matters; this duplication is intentional.

## Install

### Project-scoped

Clone this repository, then install into the repository where you want to use `equiv`:

```bash
./install.sh --repo /path/to/project
```

This installs:

```text
<project>/.agents/skills/equiv/
<project>/.codex/agents/equiv-*.toml
```

Project-scoped installation is recommended when the agent definitions should travel with a specific codebase.

### User-scoped

To make `equiv` available across repositories:

```bash
./install.sh --user
```

This installs the Skill under `~/.agents/skills/equiv/` and the custom agents under `~/.codex/agents/`.

Codex normally detects Skill changes automatically. If it does not appear, restart Codex.

## Use

Invoke it explicitly in Codex CLI or the IDE extension:

```text
$equiv Implement the requested authentication change.
```

or:

```text
$equiv Review the current design concern, implement only what is necessary, and have Audit verify it independently.
```

Implicit invocation is disabled because this workflow is materially more expensive than a normal single-agent task.

## Workflow

### 1. Main creates the brief

Main records the user's request in `.equiv/active/brief.md` without adding its own technical proposal.

### 2. Engineering and Audit inspect independently

Main starts `equiv-engineer-main` and `equiv-observer-main` from the same brief.

- Engineering determines what should be changed.
- Audit independently maps the relevant current behavior, constraints, and risks.

They should not inherit one another's conclusions before their initial positions are formed.

### 3. Engineering delegates implementation

When a code change is needed, Main relays Engineering's bounded implementation order to `equiv-engineer-implementer`.

The implementer edits only the requested scope and returns validation evidence. Main stores the result for the Engineering lead and Audit to read.

### 4. Audit reviews the actual change

Audit reviews the diff first, verifies relevant call paths and requirements, and records only actionable findings.

### 5. Findings become issues

A disagreement is represented as a small structured entry rather than a copied conversation:

```text
## I-003
status: disputed
claim: The new path bypasses the existing cooldown check.
evidence:
- src/service.rs:120-151
observer: change-required
engineer: disagree
engineer-reason: The caller performs the check before entering this path.
next: Observer verifies the caller guarantee.
```

### 6. Main reports, but does not adjudicate

If Engineering and Audit agree, Main reports the agreed result.

If a material issue remains unresolved after the bounded review loop, Main reports both positions and their evidence to the user. Main must not invent a third technical answer merely to force closure.

## Role boundaries

### Main / CEO

May:

- preserve and route the user's request;
- start, steer, wait for, and close agent threads;
- write the structured outputs returned by departments into `.equiv/`;
- relay a department's bounded delegation request to the appropriate helper;
- report agreed conclusions and unresolved disputes to the user.

Must not:

- inspect code in order to form an independent technical conclusion;
- design the implementation itself;
- review the implementation itself;
- silently rewrite a department's technical claim;
- resolve an Engineering/Audit dispute by its own technical judgment.

### Engineering

Owns technical design and implementation. It should make the smallest defensible change required by the user's goal and should not add speculative abstractions or unrelated cleanup.

### Audit

Owns independent verification. It should challenge only concrete, evidence-backed problems and may return `APPROVE` when the work is sound.

## Files

```text
skill/equiv/SKILL.md                  Skill workflow and CEO contract
skill/equiv/references/protocol.md    `.equiv/` document schemas and routing protocol
skill/equiv/scripts/start-task.sh     Deterministic runtime workspace rotation
skill/equiv/agents/openai.yaml        Skill UI metadata; implicit invocation disabled
agents/equiv-*.toml                   Custom Codex agent definitions
install.sh                            Project/user installer
```

## Current limitations

- Multi-agent work consumes more tokens than a comparable single-agent run by design.
- The parent session's model/reasoning level is selected outside the Skill.
- Codex custom-agent authoring is still evolving; agent TOML format may change in future releases.
- `equiv` serializes code-writing responsibility through one implementer. Parallel write-heavy work is intentionally avoided to reduce merge/coordination conflicts.

## Sources

- OpenAI, **Build skills**: https://developers.openai.com/codex/skills
- OpenAI, **Subagents**: https://developers.openai.com/codex/subagents
- OpenAI Codex, **code-review Skill**: https://github.com/openai/codex/blob/main/.codex/skills/code-review/SKILL.md
- OpenAI Codex, **review-agent sample**: https://github.com/openai/codex/blob/main/codex-rs/skills/src/assets/samples/review-agent/SKILL.md

## License

MIT. See [`LICENSE`](./LICENSE).
