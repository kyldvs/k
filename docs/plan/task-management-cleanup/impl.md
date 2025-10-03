# Task Management Cleanup - Implementation Plan

## Prerequisites
- No dependencies or installation required
- Working knowledge of markdown and repository structure
- Understanding of "Less but Better" principles from CLAUDE.md

## Architecture Overview
This is a documentation-only project that organizes the task management
system. The work involves:
- Creating 1 new task file (refactor-error-handling.md)
- Updating 7 existing task files with standardized sections
- Updating CLAUDE.md with Current Priorities section
- Marking 1 task as superseded

**Current State Analysis:**
- Completed projects already archived ✓
- input-validation.md already exists in docs/tasks/ ✓
- shellcheck-integration already exists in archive/ ✓
- refactor-error-handling.md needs to be created
- Most task files missing Estimated Effort and Related Principles sections

## Task Breakdown

### Phase 1: Create New Task File
- [ ] Task 1.1: Create refactor-error-handling.md
  - Files: `docs/tasks/refactor-error-handling.md`
  - Dependencies: None
  - Details: Create comprehensive task file for error handling refactor.
    Content should cover:
    * Add retry logic for network operations
    * Separate error types (error, warning, info)
    * Fix principle #6 violations (honesty - errors surface immediately)
    * Include Priority: High
    * Include Estimated Effort: 4-6 hours
    * Include Related Principles: #6 (Honest), #8 (Thorough)
    * Include Dependencies: None
  - Implementation: DIRECT (single file creation)

### Phase 2: Mark Superseded Task
- [ ] Task 2.1: Mark bootstrap-error-recovery.md as superseded
  - Files: `docs/tasks/bootstrap-error-recovery.md`
  - Dependencies: Task 1.1 (refactor-error-handling created)
  - Details: Add prominent note at top of file indicating this task has
    been superseded by refactor-error-handling.md. Explain that the new
    task has more focused scope and better aligns with principles. Keep
    file for historical reference but mark clearly as not active.
  - Implementation: DIRECT (single file edit)

### Phase 3: Standardize Existing Task Files
Update all active task files to include required sections if missing:
Priority, Estimated Effort, Related Principles, Dependencies

- [ ] Task 3.1: Update ci-integration.md
  - Files: `docs/tasks/ci-integration.md`
  - Dependencies: None
  - Details:
    * Add Priority: Medium
    * Add Estimated Effort: 2-3 hours
    * Add Related Principles: #9 (Sustainable)
    * Update Dependencies: vmroot-test-fixes
  - Implementation: DIRECT

- [ ] Task 3.2: Update termux-keyboard-config.md
  - Files: `docs/tasks/termux-keyboard-config.md`
  - Dependencies: None
  - Details:
    * Add Priority: Low
    * Add Estimated Effort: 1-2 hours
    * Add Related Principles: #2 (Useful), #5 (Unobtrusive)
    * Add Dependencies: None
  - Implementation: DIRECT

- [ ] Task 3.3: Update vm-mosh-server.md
  - Files: `docs/tasks/vm-mosh-server.md`
  - Dependencies: None
  - Details:
    * Add Priority: Low
    * Add Estimated Effort: 2-3 hours
    * Add Related Principles: #7 (Long-lasting), #2 (Useful)
    * Add Dependencies: vm-user-bootstrap (mosh should be configured
      during VM user setup)
  - Implementation: DIRECT

- [ ] Task 3.4: Update vmroot-test-fixes.md
  - Files: `docs/tasks/vmroot-test-fixes.md`
  - Dependencies: None
  - Details:
    * Verify Priority exists (should be High)
    * Add Estimated Effort: 1-2 hours
    * Add Related Principles: #8 (Thorough), #9 (Sustainable)
    * Verify Dependencies (should be None, but blocks ci-integration)
  - Implementation: DIRECT

- [ ] Task 3.5: Update vm-user-bootstrap.md
  - Files: `docs/tasks/vm-user-bootstrap.md`
  - Dependencies: None
  - Details:
    * Add Priority: Low
    * Add Estimated Effort: 8-10 hours
    * Add Related Principles: #2 (Useful), #10 (Less but Better)
    * Add Dependencies: vmroot-test-fixes (complete testing first)
  - Implementation: DIRECT

- [ ] Task 3.6: Update input-validation.md
  - Files: `docs/tasks/input-validation.md`
  - Dependencies: None
  - Details:
    * Add Priority: Medium
    * Add Estimated Effort: 2-3 hours
    * Add Related Principles: #8 (Thorough), #6 (Honest)
    * Add Dependencies: None
  - Implementation: DIRECT

- [ ] Task 3.7: Update task-management-cleanup.md (self-reference)
  - Files: `docs/tasks/task-management-cleanup.md`
  - Dependencies: None
  - Details:
    * Verify all sections present
    * This task should be marked as "in progress" or completed after
      this implementation
  - Implementation: DIRECT

### Phase 4: Update CLAUDE.md
- [ ] Task 4.1: Add Current Priorities section to CLAUDE.md
  - Files: `CLAUDE.md`
  - Dependencies: All Phase 3 tasks (need accurate priorities and
    estimates)
  - Details: Add new section after "# Development Practices" with:
    * Introduction linking to docs/principles.md
    * High Priority tasks (2): refactor-error-handling, vmroot-test-fixes
    * Medium Priority tasks (3): shellcheck-integration (archived),
      input-validation, ci-integration
    * Low Priority tasks (3): vm-user-bootstrap, vm-mosh-server,
      termux-keyboard-config
    * Completed section pointing to archive/
    * Recommended Implementation Order
  - Implementation: DIRECT (single file edit)
  - Note: Follow 80-character line limit convention

### Phase 5: Validation
- [ ] Task 5.1: Verify all task files have required sections
  - Files: All files in `docs/tasks/`
  - Dependencies: All Phase 3 tasks
  - Details: Manual check that each task file has:
    * Priority: High | Medium | Low
    * Estimated Effort: X-Y hours
    * Related Principles: #N (Name) - relevance
    * Dependencies: Task names or "None"
  - Implementation: DIRECT (manual review)

- [ ] Task 5.2: Verify CLAUDE.md priorities match task files
  - Files: `CLAUDE.md`, all task files
  - Dependencies: Task 4.1, Task 5.1
  - Details: Ensure CLAUDE.md Current Priorities section accurately
    reflects individual task priorities and estimates
  - Implementation: DIRECT (manual review)

- [ ] Task 5.3: Verify task dependencies are accurate
  - Files: All task files
  - Dependencies: Task 5.1
  - Details: Check logical consistency of dependencies:
    * ci-integration depends on vmroot-test-fixes ✓
    * vm-mosh-server depends on vm-user-bootstrap ✓
    * No circular dependencies
  - Implementation: DIRECT (manual review)

## Files to Create
- `docs/tasks/refactor-error-handling.md` - New high-priority task for
  error handling improvements

## Files to Modify
- `docs/tasks/bootstrap-error-recovery.md` - Mark as superseded
- `docs/tasks/ci-integration.md` - Add missing sections
- `docs/tasks/termux-keyboard-config.md` - Add missing sections
- `docs/tasks/vm-mosh-server.md` - Add missing sections
- `docs/tasks/vmroot-test-fixes.md` - Add missing sections
- `docs/tasks/vm-user-bootstrap.md` - Add missing sections
- `docs/tasks/input-validation.md` - Add missing sections
- `docs/tasks/task-management-cleanup.md` - Verify completeness
- `CLAUDE.md` - Add Current Priorities section

## Testing Strategy
Manual verification after implementation:
- All task files have Priority, Estimated Effort, Related Principles,
  Dependencies sections
- CLAUDE.md Current Priorities section exists and is accurate
- Task dependencies are logically consistent
- No broken links or references
- All markdown follows 80-character line limit
- bootstrap-error-recovery.md clearly marked as superseded

No automated testing needed - this is documentation-only work.

## Risk Assessment
- **Risk 1: Priority assessment may not match maintainer preferences**
  - Mitigation: Priorities based on principles alignment and explicit
    guidance from task-management-cleanup.md spec
  - Low impact: Priorities can be adjusted after implementation

- **Risk 2: Estimated effort may be inaccurate**
  - Mitigation: Use estimates from original task files where available,
    reasonable guesses for others
  - Low impact: Estimates are guidelines, not commitments

- **Risk 3: Task dependencies may not reflect actual implementation order**
  - Mitigation: Review logical dependencies carefully, consult existing
    task notes
  - Medium impact: Incorrect dependencies could lead to inefficient work
    order

## Notes

**Implementation Order:**
Follow phase order (1→2→3→4→5) for logical consistency. Phase 3 tasks
(standardizing existing files) can be done in any order or in parallel.

**80-Character Line Limit:**
CLAUDE.md enforces 80-character line limit. Be careful with Current
Priorities section formatting, especially task descriptions.

**Superseded Task Pattern:**
For bootstrap-error-recovery.md, add clear header like:
```markdown
> **⚠️ SUPERSEDED:** This task has been superseded by
> [refactor-error-handling.md](./refactor-error-handling.md) which has
> more focused scope and better aligns with principles #6 and #8.
```

**Related Principles Rationale:**
Each task should reference 1-3 principles with brief explanation of
relevance:
- refactor-error-handling → #6 (errors surface immediately), #8 (thorough)
- vmroot-test-fixes → #8 (thorough), #9 (sustainable automation)
- input-validation → #6 (honest), #8 (thorough)
- ci-integration → #9 (sustainable)
- vm-user-bootstrap → #2 (useful), #10 (complete the stack with less)

**Estimated Effort Guidelines:**
- 1-2 hours: Small, focused tasks (config, fixes)
- 2-3 hours: Medium tasks (integration, new component)
- 4-6 hours: Large tasks (refactoring, complex features)
- 8-10 hours: Very large tasks (complete systems)

**Current Priorities Section Format:**
```markdown
# Current Priorities

Tasks prioritized by "Less but Better" principles (see
docs/principles.md).

### High Priority
1. **refactor-error-handling** - Fix principle #6 violations
   - Add retry logic, separate error types
   - Est: 4-6 hours

...
```
