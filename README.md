# {{PROJECT_NAME}}

{{PROJECT_PURPOSE}}

## Project Overview

| Item | Value |
| --- | --- |
| Project type | {{PROJECT_TYPE}} |
| Primary language / stack | {{PRIMARY_LANGUAGE}} |
| External systems | {{EXTERNAL_SYSTEMS}} |
| Initialized | {{CREATED_DATE}} |

## Repository structure

- `.agent/`: persistent project facts, architecture, rules, decisions and workflows
- `.codex/config.toml`: Codex project security profile (`repo-locked`)
- `.claude/settings.json`: Claude Code tool permissions (not an OS sandbox on native Windows)
- `AGENTS.md` / `CLAUDE.md`: entry points for coding agents
- `docs/`: human-facing documentation, including `AGENT_SECURITY.md`
- `local_reference/`: local-only manuals and source files (ignored except README)
- `scripts/`: bootstrap and reproducible safety tests
- `src/` and `tests/`: implementation and verification
- `.collab/`: local agent/orchestrator runtime state, excluded from Git

## Start a new project from this template

1. Open https://github.com/justinmeichtry/llm-project-template and choose **Use this template -> Create a new repository**.
2. Clone the new repository, not this master template, to your workstation.
3. Run the bootstrap script once from the repository root:

```powershell
.\scripts\init-project.ps1
```

4. Review `.agent/PROJECT.md`, `.agent/ARCHITECTURE.md` and `.agent/RULES.md`.
5. Check the security defaults, classify the project data and verify OS sandbox compatibility before executing generated code.

## Agent security (important)

The template defaults to a **Codex `repo-locked` permission profile** and interactive Claude Code permissions. A *permission profile* describes what commands may access; **Microsoft Execution Containers (MXC)** is a separate host-side Windows sandbox backend. The template does not install or provision MXC.

On a compatible Windows 11 host with Codex CLI 0.162.0+ and MXC:

```powershell
# Run in the repo after you have trusted it locally and verified MXC
codex -c windows.sandbox=mxc

# Check /status for Profile repo-locked
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\test-agent-sandbox.ps1
```

Read [Agent security guide](docs/AGENT_SECURITY.md) for permissions, local trust, testing, optional network checks, Windows/VDI limitations and enterprise governance. A newly cloned directory requires its own Codex trust decision; the smoke test stops on failed permitted operations instead of reporting misleading access denials. **Do not trust an unfamiliar repository before inspecting its configuration and code.**

Claude Code: run `claude` from the project root after reading `.claude/settings.json`. Native Windows permissions do not provide MXC-equivalent OS isolation; stronger isolation requires a supported sandbox environment.

## Working with agents

Before changing code, read `AGENTS.md`, `.agent/PROJECT.md`, `.agent/ARCHITECTURE.md`, and `.agent/RULES.md`. Consult `.agent/DECISIONS.md` and `.agent/WORKFLOWS.md` where applicable.

Keep durable project knowledge in `.agent/`, current run state in ignored `.collab/`, and sensitive reference materials in ignored `local_reference/`. Never commit secrets or runtime files. Agents must not commit or push without explicit instruction.

## Status

Reusable scaffold. Customize project metadata and verify security on each workstation.
