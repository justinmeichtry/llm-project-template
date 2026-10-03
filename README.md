# {{PROJECT\_NAME}}

{{PROJECT\_PURPOSE}}

## Project Overview

|Item|Value|
|-|-|
|Project type|{{PROJECT\_TYPE}}|
|Primary language / stack|{{PRIMARY\_LANGUAGE}}|
|External systems|{{EXTERNAL\_SYSTEMS}}|
|Initialized|{{CREATED\_DATE}}|

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
├── local\_reference/        # Local-only reference material; not committed by default
├── scripts/                # Maintenance and bootstrap scripts
├── src/                    # Production source code
├── tests/                  # Automated tests
├── AGENTS.md               # Agent entry point
├── CLAUDE.md               # Claude Code entry point
└── .gitignore
```

## Getting Started

1\. Open the GitHub repository `justinmeichtry/llm-project-template`.



2\. Select:



&#x20;  \*\*Use this template → Create a new repository\*\*



3\. Choose a name for the new repository, for example:



&#x20;  ```text

&#x20;  my-new-data-project

4\. Run the project bootstrap script once:

```powershell
   .\\scripts\\init-project.ps1
   ```

5\. Complete any project-specific placeholders in `.agent/`.

6\. Add production code under `src/` and tests under `tests/`.

7\. Keep durable project knowledge in `.agent/`, not in chat history.

8\. Keep local/runtime agent state under `.collab/`; it is intentionally ignored by Git.

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

* **Project facts and architecture** → `.agent/`
* **Durable decisions** → `.agent/DECISIONS.md`
* **Current task/session state** → `.collab/` (local/runtime)
* **Large manuals and source documents** → `local\_reference/`
* **Generated logs, temporary outputs, secrets** → never commit

## Status

Initial project scaffold.

