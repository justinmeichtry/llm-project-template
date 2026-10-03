# Agent Instructions

This file is the default entry point for coding agents working in this repository.

## Read First

Before making changes, read:

1. `.agent/PROJECT.md`
2. `.agent/ARCHITECTURE.md`
3. `.agent/RULES.md`
4. `.agent/DECISIONS.md` when a change may affect established behavior or architecture
5. `.agent/WORKFLOWS.md` for the relevant task type

Do not duplicate durable project knowledge in this file. The `.agent/` directory is the shared source of truth.

## Default Operating Rules

- Inspect before modifying.
- Prefer the smallest correct change.
- Reuse existing abstractions before introducing new ones.
- Do not invent production data, market data, identifiers, credentials, or business facts.
- Do not silently change public behavior or interfaces.
- Preserve backward compatibility unless the task explicitly requires a breaking change.
- Add or update tests for behavior changes where practical.
- Run targeted tests after a change; run the broader relevant suite before completion.
- Review the final diff before declaring the task complete.
- Do not commit, push, merge, force-push, or modify remote branches unless explicitly requested.
- Do not modify files outside the project root without explicit approval.
- Do not install system-wide software or dependencies without explicit approval.
- Never store secrets, API keys, passwords, tokens, private certificates, or credentials in the repository.
- Update `.agent/ARCHITECTURE.md` or `.agent/DECISIONS.md` when a durable architecture decision changes.
- Keep temporary agent/session state in `.collab/`, not in `.agent/`.

## Context Discipline

Do not recursively ingest the whole repository by default.

Start with:
- repository map,
- relevant `.agent/` files,
- likely affected source files,
- relevant tests.

Load additional context only when needed.

## Completion Checklist

Before finishing:
- requested behavior is implemented,
- relevant tests pass,
- no unintended files were changed,
- no secrets or local-only files were added,
- documentation is updated if durable behavior changed,
- final diff is reviewed.
