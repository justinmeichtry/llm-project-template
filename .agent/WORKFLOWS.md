# Standard Workflows

These workflows define default operating procedures. Adapt them when the task requires it.

## Quick Change

Use for small, low-risk changes.

1. Inspect the relevant file(s).
2. Make the smallest correct change.
3. Run the most relevant test or validation.
4. Review the diff.
5. Report what changed.

Avoid manager/worker/reviewer overhead unless risk or complexity justifies it.

## Bug Fix

1. Reproduce or clearly establish the failure.
2. Identify the root cause.
3. Inspect relevant tests.
4. Add a regression test when practical.
5. Implement the smallest correct fix.
6. Run targeted tests.
7. Run the broader relevant suite.
8. Review the diff.
9. Update durable documentation only if behavior/architecture changed.

## Feature

1. Read relevant project context.
2. Inspect existing architecture and neighboring implementation.
3. Produce a short implementation plan.
4. Identify affected interfaces and tests.
5. Implement incrementally.
6. Add/update tests.
7. Run targeted and broader relevant tests.
8. Review the diff against project rules.
9. Update architecture/decision documentation when warranted.

## Refactor

1. Establish current behavior through existing tests.
2. Add characterization tests if behavior is insufficiently covered.
3. Refactor incrementally.
4. Do not change public behavior unless explicitly requested.
5. Test after each meaningful stage.
6. Review final diff for accidental behavior changes.

## Data / Pipeline Change

1. Identify the authoritative input and expected output contract.
2. Validate schema and edge cases.
3. Separate ingestion, validation, normalization, and persistence where practical.
4. Never silently coerce invalid source data into plausible values.
5. Add representative tests, including missing/invalid values.
6. Reconcile counts and key fields where applicable.
7. Document any new output contract.

## Architecture Change

1. State the problem and constraints.
2. Inspect relevant existing ADRs.
3. Compare viable alternatives.
4. Choose the smallest architecture change that solves the problem.
5. Record the decision in `DECISIONS.md`.
6. Implement incrementally.
7. Test integration boundaries.
8. Request independent review for material changes.

## Manager / Worker / Reviewer

For medium/large tasks:

### Manager
- understand objective and constraints,
- decompose the task,
- assign focused work packages,
- avoid reading unnecessary files,
- synthesize worker results.

### Worker
- operate on a narrowly scoped task,
- inspect only relevant context,
- implement and test,
- return a compact result and changed-file list.

### Reviewer
- receive the original objective, relevant rules, diff, changed files, and test results,
- remain independent from the implementer's reasoning where possible,
- report `PASS` or `CHANGES_REQUIRED`,
- do not modify files unless explicitly promoted to an implementation role.

Default to a maximum of one review/fix cycle unless the task is high risk.
