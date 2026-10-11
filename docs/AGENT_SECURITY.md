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

## One-time global Codex baseline (recommended)

Codex treats user-level config and project-level config as separate layers. **Define the default least-privilege profile once globally**, so a new clone can run with that baseline even when its project-local `.codex/config.toml` is not yet trusted. Project trust still matters if Codex needs to load a repository's own settings, hooks or exec policies. This is safer and less tedious than auto-trusting every newly cloned repository.

1. Back up `~/.codex/config.toml` and open it in a text editor.
2. In its **top-level section**, before the first TOML table heading, set `default_permissions = "repo-locked"` and `approval_policy = "never"`. If either key already exists, **edit it** rather than duplicating it.
3. If this is a **verified MXC-compatible Windows host**, configure `[windows] sandbox = "mxc"` in the appropriate Windows table to require MXC. An explicitly selected MXC backend should fail instead of silently falling back. On unverified VDI/SMB setups use `codex -c windows.sandbox=mxc` for targeted trials first.
4. Add these three `[permissions.repo-locked...]` tables **once** to the user configuration, or merge their keys if already present:

```toml
# These two keys go at the TOML root (before any [table]):
default_permissions = "repo-locked"
approval_policy = "never"

# Windows only, and only after proving native MXC works:
[windows]
sandbox = "mxc"

[permissions.repo-locked]
description = "Limit sandboxed commands to the active workspace"
extends = ":workspace"

[permissions.repo-locked.filesystem]
":root" = "deny"
":minimal" = "read"
":tmpdir" = "deny"
":slash_tmp" = "deny"

[permissions.repo-locked.network]
enabled = false
```

**Do not paste the entire block unchanged into an existing config** containing `[windows]` or `[permissions.repo-locked]` tables: TOML duplicate tables/keys break startup. Also remove or reconcile legacy `sandbox_mode` and `sandbox_workspace_write` settings; those select a different permission system. The block above is an example of the *effective merged settings*, not an installer.

After saving, open a new shell and run `codex` **from inside a single repository**, then check `/status` shows `repo-locked`. The `:workspace` policy is relative to the active workspace; starting from a broad directory such as `C:\Users\you` can give a correspondingly broad writable workspace. Prefer `codex -C "<repo-path>"`.

The template keeps a matching project-level `.codex/config.toml` for portability and explicit exceptions. For a new clone with no exceptions, **the global baseline is sufficient**; you do not need to automatically trust the cloned folder. If the project needs its own custom profile or tool settings, inspect the repository and *then* explicitly trust that exact path through Codex's prompt or `[projects.'<absolute-repo-path>'] trust_level = "trusted"` in the user config. A trust decision allows the repository's configuration to load; **it does not by itself grant additional filesystem rights**, though a trusted project config can request broader settings unless managed requirements prohibit them.

Do not try to solve onboarding by trusting the whole Desktop, user home, or fileserver. There is no guaranteed recursive trust wildcard for every future Git clone; path-specific project trust is intentional. In a company use IT-managed permissions/requirements to enforce maximum rights regardless of writable repository config.

### Configure and test on Windows

1. Install a compatible Codex CLI and update Windows. Ensure the native MXC backend works on the host.
2. Prefer the one-time global `repo-locked` baseline above. For project-specific config features, inspect and trust only the individual repository (never an entire parent directory). User-level machine paths and trust entries do not belong in Git.
3. Set the MXC backend for a session with `codex -c windows.sandbox=mxc` (or configure a verified global preference). Verify `/status` reports `Profile repo-locked` and the expected approval mode.
4. Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\test-agent-sandbox.ps1` from the project root. Add `-TestNetwork` only if a functional outside network baseline is available.
5. The `codex sandbox` diagnostic subcommand requires the explicit `--permission-profile repo-locked`, even though interactive Codex can pick up `default_permissions` from the trusted project configuration.

Test script first launches a harmless MXC command and **requires** permitted read/write operations to succeed. Only then does it evaluate negative file tests, requiring an explicit OS access-denied message. It deletes its own uniquely named probe files and directories. Config failures and launcher errors fail closed rather than producing false PASS results. If the script cannot load `repo-locked`, configure the global baseline or explicitly trust the new clone; separate clones do not inherit a prior project trust entry.

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
