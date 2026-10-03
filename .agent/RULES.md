# Project Rules

These are durable rules for humans and LLM-based development tools.

## Change Discipline

1. Inspect relevant code before modifying it.
2. Prefer minimal, targeted changes.
3. Do not refactor unrelated code unless explicitly requested.
4. Preserve public behavior unless a change is intentional and documented.
5. Reuse established project patterns before introducing new abstractions.
6. Avoid speculative abstractions and premature framework-building.

## Testing

1. Behavior changes should have tests where practical.
2. Bug fixes should include a regression test when practical.
3. Run targeted tests first.
4. Run the broader relevant suite before completion.
5. Do not suppress failing tests merely to obtain a green run.

## Data Integrity

1. Do not invent production data.
2. Do not silently substitute mock/sample data for unavailable real data.
3. Keep source data, transformed data, and generated outputs distinguishable.
4. Validate assumptions at external-system boundaries.
5. Preserve deterministic reconciliation where the project requires it.

## Git

1. Do not commit unless explicitly requested.
2. Do not push unless explicitly requested.
3. Never force-push unless explicitly authorized for that exact operation.
4. Review `git diff` before completion.
5. Keep generated, temporary, local, and secret files out of Git.

## Security

1. Never store credentials, secrets, tokens, API keys, passwords, or private certificates in the repository.
2. Do not print secrets into logs.
3. Do not weaken security controls to make development easier without explicit approval.
4. Do not access files outside the project root without explicit approval.

## Dependencies

1. Prefer existing dependencies.
2. Add dependencies only when they provide clear value.
3. Do not install system-wide software without approval.
4. Record material dependency or runtime changes in project documentation.

## Documentation

Update durable project memory when durable facts change:

- project scope → `PROJECT.md`
- architecture → `ARCHITECTURE.md`
- important decision/rationale → `DECISIONS.md`
- standard process → `WORKFLOWS.md`

Do not store transient task state in `.agent/`.

## LLM Context Efficiency

1. Do not read the entire repository by default.
2. Start with `.agent/` plus a repository map.
3. Load only files relevant to the current task.
4. Prefer summaries and pointers over duplicated file contents.
5. Keep reviewer context independent and compact.
6. Store current task/session state under `.collab/`.
