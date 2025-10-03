# Task Management Cleanup - Specification

## Overview
Organize and standardize the task documentation system to improve clarity, sustainability, and alignment with "Less but Better" principles. This involves archiving completed work, prioritizing active tasks, and updating CLAUDE.md to provide clear guidance for contributors.

## Goals
- Archive completed projects to reduce cognitive load and clarify current state
- Establish clear task priorities aligned with repository principles
- Standardize task documentation format for consistency
- Update CLAUDE.md with actionable priority guidance

## Requirements

### Functional Requirements
- FR-1: Move completed plan projects from `docs/plan/` to `archive/docs/plan/`
- FR-2: Review all tasks in `docs/tasks/` for current relevance
- FR-3: Add priority levels (High/Medium/Low) to all active tasks
- FR-4: Create "Current Priorities" section in CLAUDE.md with ordered task list
- FR-5: Standardize all task files to include: Priority, Estimated Effort, Related Principles, Dependencies
- FR-6: Document task dependencies to show implementation order
- FR-7: Create new task files identified from principles reflection
- FR-8: Mark superseded tasks as out of scope with explanation

### Non-Functional Requirements
- NFR-1: All changes must preserve existing information (archiving, not deleting)
- NFR-2: Documentation must be clear enough for new contributors to understand priorities
- NFR-3: Changes must align with principles #4 (Understandable), #9 (Sustainable), #10 (Less Code)

### Technical Requirements
- Use existing archive directory structure
- Maintain markdown format for all documentation
- Preserve all existing task metadata and status.md files
- Follow repository's 80-character line limit convention

## User Stories / Use Cases
- As a contributor, I want to see prioritized tasks so that I know where to focus effort
- As Claude Code, I want clear task priorities in CLAUDE.md so that I can recommend appropriate work
- As a maintainer, I want completed work archived so that I can focus on current state
- As a new contributor, I want standardized task format so that I can quickly understand scope and effort

## Success Criteria
- All 3 completed projects (bootstrap-profile-init, modular-bootstrap, vm-root-bootstrap) moved to `archive/docs/plan/`
- All tasks in `docs/tasks/` have Priority, Estimated Effort, Related Principles, and Dependencies sections
- CLAUDE.md contains "Current Priorities" section with 6+ prioritized tasks
- Task dependencies documented (e.g., ci-integration depends on vmroot-test-fixes)
- New task files created based on principles reflection (refactor-error-handling, shellcheck-integration, input-validation)
- bootstrap-error-recovery.md marked as superseded by refactor-error-handling.md
- All documentation links remain valid after archiving

## Constraints
- Must not delete any existing work (archive only)
- Must maintain backward compatibility with existing task file format
- Changes limited to documentation only (no code changes)
- Must complete within estimated 1-hour effort

## Non-Goals
This project will NOT:
- Implement any of the tasks being organized
- Create GitHub project boards or external tracking systems
- Refactor the task system structure itself
- Add automated tooling for task management
- Create additional documentation beyond what's specified

## Assumptions
- The 3 completed projects listed have no remaining work
- Priority assessment in task file is accurate and agreed upon
- New task files mentioned (refactor-error-handling, shellcheck-integration, input-validation) are valid and needed
- Current task system structure (docs/tasks/, docs/plan/, archive/) is appropriate

## Open Questions
- Should archived projects maintain their full directory structure or just status.md?
  - **Resolution**: Keep full structure for historical reference
- Should tasks-done/ be used for completed task files or only archive/docs/plan/?
  - **Resolution**: Use archive/docs/plan/ for consistency; tasks-done/ can remain as stub
- Should the "Current Priorities" section include all tasks or just top 5-7?
  - **Resolution**: Include all active tasks, organized by priority tier
- Should bootstrap-error-recovery.md be deleted or marked as superseded?
  - **Resolution**: Mark as superseded with note pointing to replacement

## Detailed Scope

### Archive Operations
Move these directories:
- `docs/plan/bootstrap-profile-init/` → `archive/docs/plan/bootstrap-profile-init/`
- `docs/plan/modular-bootstrap/` → `archive/docs/plan/modular-bootstrap/`
- `docs/plan/vm-root-bootstrap/` → `archive/docs/plan/vm-root-bootstrap/`

### New Task Files to Create
1. **refactor-error-handling.md** (High Priority)
   - Add retry logic for network operations
   - Separate error types (error, warning, info)
   - Fix principle #6 violations (honesty)
   - Estimated: 4-6 hours

2. **shellcheck-integration.md** (Medium Priority)
   - Automated shell script linting
   - Quick to implement, high value
   - Supports principle #9 (sustainability)
   - Estimated: 2-3 hours

3. **input-validation.md** (Medium Priority)
   - Validate user inputs immediately
   - Improve principle #8 (thoroughness)
   - Estimated: 2-3 hours

### Existing Tasks to Update
All files in `docs/tasks/` need standardized sections:
- bootstrap-error-recovery.md → Mark as superseded
- ci-integration.md → Medium priority, depends on vmroot-test-fixes
- termux-keyboard-config.md → Low priority
- vm-mosh-server.md → Low priority
- vm-user-bootstrap.md → Low priority, large effort
- vmroot-test-fixes.md → High priority, blocks CI

### CLAUDE.md Changes
Add new section after "# Development Practices":

```markdown
# Current Priorities

Tasks are prioritized to align with "Less but Better" principles (see docs/principles.md).

### High Priority
1. **refactor-error-handling** - Fix principle #6 violations (honesty)
   - Add retry logic for network operations
   - Separate error types (error, warning, info)
   - Est: 4-6 hours

2. **vmroot-test-fixes** - Blocks CI integration
   - Fix exit 255 issue in vmroot tests
   - Est: 1-2 hours

### Medium Priority
3. **shellcheck-integration** - Automated code quality
   - Quick to implement, high value for principle #9 (sustainability)
   - Est: 2-3 hours

4. **input-validation** - Improve principle #8 (thoroughness)
   - Validate user inputs immediately
   - Est: 2-3 hours

5. **ci-integration** - Automated testing
   - GitHub Actions for test automation
   - Depends on: vmroot-test-fixes
   - Est: 2-3 hours

### Low Priority
6. **vm-user-bootstrap** - Complete VM setup
   - Large feature, non-urgent
   - Est: 8-10 hours

7. **vm-mosh-server** - Mosh server setup on VM
   - Est: 2-3 hours

8. **termux-keyboard-config** - Keyboard layout configuration
   - Est: 1-2 hours

### Completed
See archive/docs/plan/ for completed projects:
- bootstrap-profile-init
- modular-bootstrap
- vm-root-bootstrap

### Recommended Implementation Order
1. shellcheck-integration (quick win)
2. refactor-error-handling (high value)
3. input-validation (complements error handling)
4. vmroot-test-fixes (unblocks CI)
5. ci-integration (automation)
6. vm-user-bootstrap (complete the stack)
```

## Testing Strategy
Manual verification after implementation:
- Verify archived projects accessible at new paths
- Verify all links in CLAUDE.md resolve correctly
- Verify task priority logic makes sense
- Verify dependencies are accurately documented
- Verify new task files follow template format
- Verify superseded task clearly points to replacement

## Related Principles
- **#9 Good Code is Sustainable**: Organized documentation reduces cognitive load
- **#4 Good Code is Understandable**: Clear priorities help contributors
- **#10 As Little Code as Possible**: Remove clutter by archiving old work
- **#2 Good Code is Useful**: Focus on what matters through prioritization
