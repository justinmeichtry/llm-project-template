# Architecture

## Overview

Describe the system in 5–15 lines. Prefer a compact explanation over a complete implementation narrative.

For a new project, begin with:

```text
Input
  ↓
Application / processing layer
  ↓
Storage / external systems
  ↓
Output
```

Replace this with the real architecture once implementation begins.

## Components

### Core Application

**Purpose:**  
Contains production logic.

**Primary path:**  
`src/`

**Responsibilities:**
- implement project behavior,
- expose stable interfaces,
- avoid leaking environment-specific concerns into core logic.

### Tests

**Purpose:**  
Verify behavior and prevent regressions.

**Primary path:**  
`tests/`

### Documentation

**Purpose:**  
Human-readable operational and technical documentation.

**Primary path:**  
`docs/`

### Agent Context

**Purpose:**  
Provide compact, durable context to LLM-based development tools.

**Primary path:**  
`.agent/`

Runtime state belongs in `.collab/`, not here.

## Data / Control Flow

Document the actual flow once known.

Example:

```text
Source
  ↓
Validation
  ↓
Normalization
  ↓
Business logic
  ↓
Persistence / API
  ↓
Output
```

## Boundaries

Record important boundaries explicitly.

Examples:
- core domain logic must not depend directly on UI code,
- external provider calls should be isolated behind adapters,
- parsing and validation should be separate from persistence,
- generated output should not become source-of-truth state.

## Interfaces

List only important stable interfaces, APIs, file contracts, schemas, or CLI entry points.

## Persistence

Describe databases, files, caches, and their role.

If there is no persistence, state that explicitly.

## External Integrations

Document:
- integration name,
- purpose,
- protocol/interface,
- authentication mechanism at a conceptual level,
- failure behavior.

Never store secrets.

## Architecture Update Rule

Update this file when:
- a component boundary changes,
- a new major subsystem is introduced,
- a data flow changes materially,
- an external integration becomes architecturally important.

For decisions with alternatives and rationale, also add an ADR to `DECISIONS.md`.
