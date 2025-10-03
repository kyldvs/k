# Task Management Cleanup

## Description

Organize task documentation to align with "Less but Better" principle #9 (Good Code is Sustainable) and #4 (Good Code is Understandable). Current task system has the right structure but needs hygiene: completed tasks should be archived, priorities should be clear, and CLAUDE.md should reflect current state.

## Current State

**Task System:**
- `docs/tasks/` contains 6 pending task files
- `docs/tasks-done/` directory exists but is empty (stub)
- `docs/plan/` contains 3 completed projects + 1 archived
- CLAUDE.md documents the task system but doesn't prioritize tasks

**Existing Tasks:**
```
docs/tasks/
├── bootstrap-error-recovery.md
├── ci-integration.md
├── termux-keyboard-config.md
├── vm-mosh-server.md
├── vm-user-bootstrap.md
└── vmroot-test-fixes.md
```

**Completed Work (not yet archived):**
```
docs/plan/
├── bootstrap-profile-init/      # Completed
├── modular-bootstrap/           # Completed
└── vm-root-bootstrap/           # Completed
```

## Scope

**1. Archive Completed Projects:**
- Move completed plan dirs to `archive/docs/plan/`
- Keep status.md for historical reference
- Update any references in documentation

**2. Review and Update Active Tasks:**
- Assess current relevance of each task
- Update priority/status based on principles alignment
- Add new tasks from principles reflection
- Mark dependencies between tasks

**3. Update CLAUDE.md:**
- Add "Current Priorities" section
- List tasks in priority order with brief descriptions
- Document recommended implementation order
- Link to principles.md for context

**4. Standardize Task Format:**
- Ensure all tasks follow template (Description, Scope, Success Criteria, etc.)
- Add "Related Principles" section to existing tasks
- Add estimated effort to all tasks

## Success Criteria

- [ ] All completed projects moved to archive/
- [ ] docs/tasks/ contains only active, relevant tasks
- [ ] Each task has priority level (High/Medium/Low)
- [ ] CLAUDE.md has "Current Priorities" section
- [ ] Task dependencies documented
- [ ] All tasks reference relevant principles
- [ ] Clear next steps for contributors

## Implementation Notes

**Archive Completed Projects:**
```bash
# Move completed plan projects
mkdir -p archive/docs/plan
mv docs/plan/bootstrap-profile-init archive/docs/plan/
mv docs/plan/modular-bootstrap archive/docs/plan/
mv docs/plan/vm-root-bootstrap archive/docs/plan/
```

**Task Priority Assessment:**

High Priority (Principle Violations):
- refactor-error-handling.md (new) - Fixes honesty violations
- vmroot-test-fixes.md - Blocks CI integration

Medium Priority (Sustainability):
- shellcheck-integration.md (new) - Quick win, high value
- input-validation.md (new) - Improves thoroughness
- ci-integration.md - Automation for sustainability

Low Priority (Features):
- vm-user-bootstrap.md - New feature, not urgent
- vm-mosh-server.md - Enhancement
- termux-keyboard-config.md - Nice-to-have

Out of Scope (Superseded):
- bootstrap-error-recovery.md - Superseded by refactor-error-handling.md

**Add to CLAUDE.md:**
```markdown
## Current Priorities

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
8. **termux-keyboard-config** - Keyboard layout configuration

### Completed
- bootstrap-profile-init (see archive/)
- modular-bootstrap (see archive/)
- vm-root-bootstrap (see archive/)

### Recommended Order
1. shellcheck-integration (quick win)
2. refactor-error-handling (high value)
3. input-validation (complements error handling)
4. vmroot-test-fixes (unblocks CI)
5. ci-integration (automation)
6. vm-user-bootstrap (complete the stack)
```

**Update Each Task File:**
Add sections if missing:
- Priority: High | Medium | Low
- Estimated Effort: X hours
- Related Principles: #N Name - Why relevant
- Dependencies: Task names or "None"

## Testing Strategy

No automated testing needed. Manual verification:
- [ ] All archived projects still accessible
- [ ] CLAUDE.md links work
- [ ] Task priority makes sense
- [ ] Dependencies are correct

## Related Principles

- **#9 Good Code is Sustainable**: Organized documentation reduces cognitive load
- **#4 Good Code is Understandable**: Clear priorities help contributors
- **#10 As Little Code as Possible**: Remove clutter (archive old work)
- **#2 Good Code is Useful**: Focus on what matters (prioritize)

## Dependencies

None - organizational task

## Related Files

- `docs/tasks/*.md` (review and update)
- `CLAUDE.md` (add priorities section)
- `archive/docs/plan/` (move completed work)
- New task files from principles reflection

## Related Tasks

All tasks benefit from clear prioritization

## Priority

**Low** - Organizational, not blocking development

## Related Principles

- **#9 Good Code is Sustainable**: Organized documentation reduces cognitive
  load and enables long-term maintainability
- **#4 Good Code is Understandable**: Clear priorities help contributors
  understand what matters most
- **#10 As Little Code as Possible**: Archive old work to remove clutter
- **#2 Good Code is Useful**: Focus on what matters through prioritization

## Dependencies

None - organizational task

## Incremental Approach

1. Create new task files from principles reflection
2. Archive completed plan projects
3. Review and update existing task files (add priorities, principles)
4. Update CLAUDE.md with Current Priorities section
5. Commit changes
6. (Optional) Create GitHub project board for task tracking

## Estimated Effort

1 hour

## Notes

This is "meta-work" but valuable. Clear priorities help contributors (including future Claude sessions) understand what matters. Following principle #4 (Understandable) applies to project management, not just code.
