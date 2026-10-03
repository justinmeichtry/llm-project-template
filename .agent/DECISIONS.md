# Architecture Decision Records

Use this file for durable decisions where future developers or agents need to understand **why** something was chosen.

Do not record trivial implementation details.

---

## ADR-000 — Repository Memory Structure

**Status:** Active  
**Date:** {{CREATED_DATE}}

### Decision

The repository uses:

- `.agent/` for durable, version-controlled project context,
- `.collab/` for local/runtime agent state,
- `local_reference/` for local-only reference material,
- `AGENTS.md` and `CLAUDE.md` as lightweight entry points rather than duplicated project documentation.

### Reason

This separates durable project knowledge from transient chat/session state and avoids maintaining different versions of project truth for different LLM tools.

### Alternatives Considered

- one large `MEMORY.md`,
- tool-specific project documentation only,
- relying on chat history.

### Consequences

- project knowledge remains portable across tools,
- context can be loaded selectively,
- session state does not pollute Git,
- maintainers must keep `.agent/` current when durable facts change.

---

## ADR Template

Copy the block below for new decisions.

```markdown
## ADR-XXX — Short Title

**Status:** Proposed | Active | Superseded | Rejected  
**Date:** YYYY-MM-DD

### Decision

What was decided?

### Reason

Why was this chosen?

### Alternatives Considered

- Alternative A
- Alternative B

### Consequences

What becomes easier, harder, constrained, or required?

### Supersedes / Superseded By

Optional.
```
