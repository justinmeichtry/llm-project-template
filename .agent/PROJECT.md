# Project Memory

## Identity

**Project name:** {{PROJECT_NAME}}

**Purpose:**  
{{PROJECT_PURPOSE}}

**Project type:** {{PROJECT_TYPE}}

**Primary language / stack:** {{PRIMARY_LANGUAGE}}

**External systems:** {{EXTERNAL_SYSTEMS}}

## Current State

Initial scaffold. Replace this section with a concise description of what is already implemented and what is currently operational.

Keep this section short enough that an agent can understand the current state without reading the full repository.

## Main Components

Document only durable components.

| Component | Purpose | Important paths |
|---|---|---|
| Core application | Main production logic | `src/` |
| Tests | Automated verification | `tests/` |
| Documentation | Human-facing documentation | `docs/` |
| Local references | Manuals, sample source files, vendor docs | `local_reference/` |

Add project-specific components as the repository evolves.

## External Dependencies and Systems

Record systems that materially affect implementation, for example:

- databases,
- APIs,
- cloud services,
- brokers/custodians,
- vendor systems,
- file formats,
- runtime environments.

Do not store credentials here.

## Important Paths

- `src/` — production source
- `tests/` — automated tests
- `.agent/` — durable shared project memory
- `.collab/` — local orchestrator/session state; not versioned
- `local_reference/` — local-only reference files; not versioned by default
- `docs/` — human-facing documentation
- `scripts/` — maintenance and bootstrap scripts

## Current Priorities

1. Replace scaffold placeholders with project-specific information.
2. Establish the minimal working implementation.
3. Add tests for critical behavior.
4. Record durable decisions in `DECISIONS.md`.

## Known Constraints

Add constraints that materially affect implementation, such as:

- restricted network access,
- no administrator rights,
- production data handling rules,
- deployment restrictions,
- regulatory constraints,
- platform requirements.

## Known Issues

None recorded yet.

## Memory Maintenance Rules

Update this file when:
- project scope materially changes,
- major components are added or removed,
- important external systems change,
- current priorities materially change.

Do not use this file as a task log or chat transcript.
