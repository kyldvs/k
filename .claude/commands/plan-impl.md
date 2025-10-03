---
description: Create implementation plan from specification
---

# Determine Project

$ARGUMENTS

If no project name was provided:
- Check if a spec was just created in the current context - use that project
- If no recent spec exists, ask the user for the project name
- Use best guess matching from user input to find the relevant plan if project name isn't exact

# Process

1. **Locate Specification**: Read `docs/plan/[project-name]/spec.md`
   - If not found, suggest running `/plan/spec` first

2. **Analyze Codebase**: Understand current architecture and patterns
   - Identify relevant existing files and modules
   - Determine integration points
   - Assess impact on existing code

3. **Plan Implementation**: Break down the work into actionable tasks

4. **Commit Document**: After completing the implementation plan, use `/git` to commit the impl document.

## Implementation Plan Template

```markdown
# [Project Name] - Implementation Plan

## Prerequisites
- Dependencies to install
- Environment setup required
- Prerequisite knowledge or access

## Architecture Overview
Brief description of how this fits into existing codebase:
- Key files/modules to create or modify
- Data flow and component interactions
- Integration points with existing systems

## Task Breakdown

### Phase 1: Foundation
- [ ] Task 1.1: Specific atomic task
  - Files: `path/to/file.ext`
  - Dependencies: None
  - Details: Implementation notes

- [ ] Task 1.2: Next task
  - Files: `path/to/other.ext`
  - Dependencies: Task 1.1
  - Details: ...

### Phase 2: Core Implementation
- [ ] Task 2.1: ...
- [ ] Task 2.2: ...

### Phase 3: Integration & Polish
- [ ] Task 3.1: ...
- [ ] Task 3.2: ...

### Phase 4: Testing & Validation
- [ ] Task 4.1: Write tests for...
- [ ] Task 4.2: Validate against success criteria
- [ ] Task 4.3: Test edge cases

## Files to Create
- `path/to/new/file1.ext` - Purpose
- `path/to/new/file2.ext` - Purpose

## Files to Modify
- `path/to/existing1.ext` - Changes needed
- `path/to/existing2.ext` - Changes needed

## Testing Strategy
- Unit tests for: [components]
- Integration tests for: [workflows]
- Manual verification steps:
  1. Step 1
  2. Step 2

## Risk Assessment
- Risk 1: Description and mitigation
- Risk 2: Description and mitigation

## Notes
- Important implementation considerations
- Potential gotchas or edge cases
- Performance or security considerations
```

# Output

Create the implementation plan at `docs/plan/[project-name]/impl.md`

# Guidelines

- **Atomic Tasks**: Each task should be independently completable
- **Clear Dependencies**: Explicitly state what must be done first
- **Specific Paths**: Include actual file paths, not placeholders
- **Pattern Matching**: Follow existing codebase patterns (check CLAUDE.md)
- **DRY Principle**: Identify opportunities to reuse existing code
- **Test Coverage**: Include testing tasks for each significant component
- **Task Sizing**: Break large tasks into smaller, manageable subtasks

# Task Delegation Patterns

Based on CLAUDE.md principles, suggest when to use:
- **Direct implementation**: 1-4 files, simple changes
- **Agent delegation**: Complex logic, parallel work, large investigations
- **Parallel agents**: Independent changes that can run simultaneously

Example task annotations:
```
- [ ] Task: Implement authentication (AGENT: backend-developer)
- [ ] Task: Update UI for login form (PARALLEL with above)
- [ ] Task: Fix typo in config (DIRECT)
```
