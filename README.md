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

**Scope: MXC has been tested for Codex CLI only. It is NOT configured or verified as an MXC sandbox for Claude Code.** The `.claude/settings.json` file supplies Claude tool permissions, not Codex's OS-level isolation. Treat any future Claude process sandbox as a separate project.

The template defaults to a **Codex `repo-locked` permission profile** and interactive Claude Code permissions. A *permission profile* describes what commands may access; **Microsoft Execution Containers (MXC)** is a separate host-side Windows sandbox backend. The template does not install or provision MXC.

**Recommended for frequent use:** install the same `repo-locked` profile once in your **user-level** `~/.codex/config.toml` and select MXC on the Windows host. This gives every new repo a safe baseline **even before its project config is trusted**. Trust only repositories whose project-local settings you deliberately want to load; global profile enforcement and project-config trust are different controls.

See [Agent security guide](docs/AGENT_SECURITY.md#one-time-global-codex-baseline-recommended) for a copyable global baseline, avoiding duplicate TOML sections, per-project trust, explicit file/folder allowlists, approval behavior, and Full Access limitations.

On a compatible Windows 11 host with Codex CLI 0.162.0+ and MXC:

```powershell
# Run in the repo; project config is optional when global baseline is installed
codex -c windows.sandbox=mxc

# Confirm /status shows Profile repo-locked (workspace, never)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\test-agent-sandbox.ps1
```

The smoke test stops on failed permitted operations instead of treating launch/config errors as security denials. **Do not automatically trust unfamiliar repositories or your entire home folder.**

Claude Code: run `claude` from the project root after reading `.claude/settings.json`. Native Windows permissions do not provide MXC-equivalent OS isolation; stronger isolation requires a supported sandbox environment.

## Working with agents

Before changing code, read `AGENTS.md`, `.agent/PROJECT.md`, `.agent/ARCHITECTURE.md`, and `.agent/RULES.md`. Consult `.agent/DECISIONS.md` and `.agent/WORKFLOWS.md` where applicable.

Keep durable project knowledge in `.agent/`, current run state in ignored `.collab/`, and sensitive reference materials in ignored `local_reference/`. Never commit secrets or runtime files. Agents must not commit or push without explicit instruction.

## Status

Reusable scaffold. Customize project metadata and verify security on each workstation.
