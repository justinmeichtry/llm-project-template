# Agent security: Codex, MXC, and Claude Code

## Purpose and separation of responsibility

- **MXC** is an OS-backed execution environment on a compatible Windows host. It is not installed into a repository or on a file server serving source files.
- **Codex permission profiles** are Codex configuration; the effective sandbox backend enforces the restrictions for supported sandboxed commands. Project configuration is not an immutable enterprise security control.
- **Claude Code project permissions** constrain its tool usage. On native Windows they are **not** equivalent to an OS-level sandbox for arbitrary subprocesses.
- **AGENTS.md and CLAUDE.md** are behavioral instructions, not access-control boundaries.

## Default Codex profile

Every new repository copied from this template includes `.codex/config.toml` with `default_permissions = "repo-locked"`. It inherits `:workspace`, denies general reads outside the workspace, allows minimal runtime reads, denies general temporary roots and disables network access for sandboxed commands. It also uses `approval_policy = "never"` to avoid approval-based elevation during default runs.

These restrictions apply to supported sandboxed commands. They **do not** restrict model API calls, web-search services, cloud tools, external MCP servers, or all other integrations by themselves. A custom Python runtime may require narrowly scoped additional read access and a project-local temp folder. Never grant an entire company drive for convenience.

**Compatibility:** Tested manually with Codex CLI `0.162.1`, MXC on Windows 11 build `26200.9457`. Other hosts must verify compatibility; enabling this project profile does not automatically turn on MXC everywhere. Do not mix the new permission profile configuration with legacy `sandbox_mode` settings.

### Configure and test on Windows

1. Install a compatible Codex CLI and update Windows. Ensure the native MXC backend works on the host.
2. Mark **only repositories you trust** as trusted in your personal `~/.codex/config.toml`; this is machine/user state, not repository content. Avoid committing machine-specific absolute paths.
3. Set the MXC backend for a session with `codex -c windows.sandbox=mxc` (or configure a verified global preference). Verify `/status` reports `Profile repo-locked` and the expected approval mode.
4. Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\test-agent-sandbox.ps1` from the project root. Add `-TestNetwork` only if a functional outside network baseline is available.
5. The `codex sandbox` diagnostic subcommand requires the explicit `--permission-profile repo-locked`, even though interactive Codex can pick up `default_permissions` from the trusted project configuration.

Test script checks reading and writing inside the repository and rejection of reading/writing outside plus a sibling directory. It deletes only its own uniquely named probe files and directories. A failure before command execution (for example, TOML validation or unknown profile) is **not** a successful access-denial test.

## Claude Code

`.claude/settings.json` enables `blockReadsOutsideWorkingDirectories` and explicitly denies built-in read/edit tools from handling `.env` and `secrets` files. The default permission mode remains interactive. This feature needs a compatible Claude Code version (v2.1.257+).

**Native Windows caveat:** these rules are not an OS sandbox for arbitrary shell programs. Use an approved isolated host, WSL2/Linux sandbox, or another isolation solution for stronger process-level enforcement. Never assume Codex MXC also contains a separate Claude process.

Keep personal overrides in `.claude/settings.local.json` (Git ignored). Do not place secrets, API keys, personal paths or corporate drive names in committed settings.

## Company VDI and network shares

- The isolation boundary applies where the CLI process executes (typically the Windows VDI), even if the executable or repository is stored on an SMB file server.
- Test both mapped-drive and UNC paths, adjacent company projects, project-local Python/Git runtimes, temp directories and VDI persistence before approving wider use.
- An SMB share may require network access; a completely network-denied profile may prevent all access to it. Do not lift network restrictions without testing and an allow-list design.
- IT-managed policies, Windows identities, NTFS/SMB ACLs, endpoint controls, logging, data-export rules and approval workflows remain necessary.
- This public template intentionally contains no company-specific policies or paths.

## Before production use

Verify the effective profile with `/status`; perform both positive and negative tests; check subprocesses and MCP bypass paths; review logs, egress, secrets exposure, and any tool-specific exceptions. A sandbox test proves only the exercised cases, not blanket protection. Run enterprise use cases only with an approved account, data classification and IT sign-off.
