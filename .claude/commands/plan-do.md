---
description: Autonomously implement tasks from implementation plan
---

# Determine Project

$ARGUMENTS

If no project name was provided:
- Check if an impl was just created in the current context - use that project
- If no recent impl exists, ask the user for the project name
- Use best guess matching from user input to find the relevant plan if project name isn't exact

# Process

1. **Load Implementation Plan**: Read `docs/plan/[project-name]/impl.md`
   - If not found, suggest running `/plan/impl` first

2. **Initialize Status Tracking**: Create or update `docs/plan/[project-name]/status.md`

3. **Execute Tasks Autonomously**:
   - Work through tasks in dependency order
   - Follow codebase conventions from CLAUDE.md
   - Use appropriate delegation (direct vs agent)
   - Track progress in real-time

4. **Commit at Milestones**: Use `/git` command after completing major milestones or phases

5. **Update Documentation**:
   - Mark completed tasks in impl.md
   - Record progress, notes, and issues in status.md
   - Document any new tasks that emerged

## Status File Template

```markdown
# [Project Name] - Implementation Status

**Status**: In Progress | Blocked | Completed

## Progress Summary
- Tasks Completed: X / Y
- Current Phase: [phase name]
- Estimated Completion: [percentage]%

## Currently Working On
- Task: [current task description]
- Files: [files being modified]

## Completed Tasks
- [x] Task 1.1: Description
  - Notes: Any important decisions or findings
- [x] Task 1.2: Description

## In Progress
- [ ] Task 2.1: Description
  - Current status: What's been done so far
  - Next steps: What remains

## Blocked / Issues
- [ ] Task X: Description
  - Blocker: What's preventing progress
  - Resolution needed: What needs to happen

## Future Tasks Discovered
Tasks that emerged during implementation:
- [ ] New Task 1: Description
  - Why: Reason this became necessary
  - Priority: High | Medium | Low

## Notes & Decisions
- Decision 1: Why we chose approach X over Y
- Finding 1: Important discovery during implementation
- Gotcha 1: Edge case or issue encountered

## Testing Status
- [ ] Unit tests: X / Y passing
- [ ] Integration tests: Status
- [ ] Manual verification: Completed items

## Next Session
Priority items for next work session:
1. Task to resume or start
2. Issue to resolve
3. Testing to complete
```

# Execution Guidelines

## Code Quality
- Study existing patterns before creating new files
- Extend existing components over creating new ones
- Match established conventions
- Use precise types (research actual types, avoid `any`)
- Fail fast with clear errors

## Task Management
- Work in dependency order (prerequisites first)
- Complete one task fully before moving to the next
- Update status.md after each significant change
- Mark tasks in impl.md with `[x]` when complete
- Use `/git` to commit and push after completing major milestones or phases

## When to Use Agents
- Complex features with intricate logic (use Task tool with general-purpose agent)
- Parallel independent tasks (launch multiple agents)
- Large code investigations
- Multi-step plans requiring autonomy

## When to Work Directly
- Small scope (1-4 files)
- Quick fixes or simple changes
- Active debugging requiring rapid iteration

## Error Handling
- If a task fails, document in status.md under "Blocked / Issues"
- If you discover new requirements, add to "Future Tasks Discovered"
- If approach needs to change, update impl.md with rationale

## Completion Criteria
Mark task as complete only when:
- Code is written and tested
- Tests pass (if applicable)
- No blocking errors remain
- Code follows project conventions

# Output

Throughout execution:
- Keep status.md updated with current progress
- Mark completed tasks in impl.md with `[x]`
- Document decisions and discoveries in status.md
- Report blockers immediately
- Use `/git` to commit after completing major milestones

Final confirmation:
- Summary of tasks completed
- Any blockers or issues encountered
- Next steps or remaining work
- Location of status.md for review
