# Claude Code Instructions

Use `AGENTS.md` as the primary operating instructions for this repository.

Before modifying code, read:

- `.agent/PROJECT.md`
- `.agent/ARCHITECTURE.md`
- `.agent/RULES.md`

Consult:
- `.agent/DECISIONS.md` before changing established architecture or behavior
- `.agent/WORKFLOWS.md` for the relevant task workflow

Do not duplicate project memory here. Durable knowledge belongs in `.agent/`.

Default safety:
- inspect before editing,
- keep changes scoped,
- run relevant tests,
- do not commit or push unless explicitly requested,
- do not access or modify files outside the project root without approval.
