# {{PROJECT_NAME}}

{{PROJECT_PURPOSE}}

## Project Overview

| Item | Value |
|---|---|
| Project type | {{PROJECT_TYPE}} |
| Primary language / stack | {{PRIMARY_LANGUAGE}} |
| External systems | {{EXTERNAL_SYSTEMS}} |
| Initialized | {{CREATED_DATE}} |

## Repository Structure

```text
.
├── .agent/                 # Shared long-term project context for LLMs and humans
│   ├── PROJECT.md
│   ├── ARCHITECTURE.md
│   ├── RULES.md
│   ├── DECISIONS.md
│   └── WORKFLOWS.md
├── docs/                   # Human-facing documentation
├── local_reference/        # Local-only reference material; not committed by default
├── scripts/                # Maintenance and bootstrap scripts
├── src/                    # Production source code
├── tests/                  # Automated tests
├── AGENTS.md               # Agent entry point
├── CLAUDE.md               # Claude Code entry point
└── .gitignore
```

## Getting Started

1. Run the project bootstrap script once:

   ```powershell
   .\scripts\init-project.ps1
   ```

2. Complete any project-specific placeholders in `.agent/`.
3. Add production code under `src/` and tests under `tests/`.
4. Keep durable project knowledge in `.agent/`, not in chat history.
5. Keep local/runtime agent state under `.collab/`; it is intentionally ignored by Git.

## LLM / Agent Usage

Before making changes, coding agents should read:

1. `AGENTS.md`
2. `.agent/PROJECT.md`
3. `.agent/ARCHITECTURE.md`
4. `.agent/RULES.md`
5. `.agent/DECISIONS.md` when architecture or prior decisions are relevant
6. `.agent/WORKFLOWS.md` for the applicable workflow

The repository is designed so that Claude Code, Codex CLI, a custom orchestrator, and human developers share the same durable source of truth.

## Documentation Principle

Use the smallest useful amount of persistent context:

- **Project facts and architecture** → `.agent/`
- **Durable decisions** → `.agent/DECISIONS.md`
- **Current task/session state** → `.collab/` (local/runtime)
- **Large manuals and source documents** → `local_reference/`
- **Generated logs, temporary outputs, secrets** → never commit

## Status

Initial project scaffold.
