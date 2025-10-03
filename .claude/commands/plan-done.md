---
description: Finalize completed plan by archiving to design docs
---

# Determine Project

$ARGUMENTS

If no project name was provided:
- Check if a plan was just completed in the current context - use that project
- If no recent completion exists, ask the user for the project name
- Use best guess matching from user input to find the relevant plan if project name isn't exact

# Process

1. **Load Plan Documents**: Read `docs/plan/[project-name]/{spec,impl,status}.md`
   - If not found, ask user to confirm project name

2. **Extract Persistent Architecture Information**:
   - Read all plan documents to understand what was built
   - Identify architecture patterns, design decisions, and implementation approaches that are persistently useful
   - **Exclude**: Temporary justifications, time estimates, ephemeral status updates, task checklists
   - **Include**: System architecture, component relationships, design patterns used, key technical decisions with rationale, integration points, API contracts, data models, reusable patterns

3. **Create/Update Architecture Documentation**:
   - Determine appropriate design doc(s) in `docs/design/[name].md`
   - May create multiple design docs if plan covered distinct architectural areas
   - Create `docs/design/` directory if it doesn't exist
   - Follow "Less but Better" principle (docs/principles.md): only include what's useful long-term

4. **Update Design Index**:
   - Create or update `docs/design/index.md`
   - Add 1-sentence description for each design doc
   - Keep index concise and scannable

5. **Move Task Files**:
   - Find any related task files in `docs/tasks/` that match this project
   - Move them to `docs/tasks-done/`
   - Preserve filenames

6. **Delete Plan Documents**:
   - Remove entire `docs/plan/[project-name]/` directory
   - Plan documents are ephemeral; design docs are permanent

7. **Commit Changes**: Use `/git` to commit all changes

## Design Document Template

```markdown
# [Component/Feature Name]

## Overview
2-3 sentence summary of what this is and why it exists.

## Architecture
High-level structure and component relationships.

## Key Components
- **Component 1**: Purpose and responsibility
- **Component 2**: Purpose and responsibility

## Design Decisions
- **Decision 1**: What was chosen and why (permanent rationale only)
- **Decision 2**: Trade-offs considered and outcome

## Implementation Patterns
Reusable patterns established:
- Pattern 1: When and how to use
- Pattern 2: ...

## Integration Points
How this connects to other parts of the system:
- Integration 1: Protocol, contract, or interface
- Integration 2: ...

## Data Models
Key data structures (if applicable):
```
[Structure definition]
```

## Configuration
Important configuration points and options.

## Testing Approach
How this component is tested (strategy, not task list).

## Future Considerations
Potential extensions or known limitations.
```

## Design Index Template

```markdown
# Architecture Documentation

This directory contains persistent design documentation extracted from completed projects.

## Documents

- **[name].md** - One sentence description
- **[name2].md** - One sentence description
```

# Guidelines

## What to Include in Design Docs
- ✅ System architecture and component relationships
- ✅ Design patterns and reusable approaches
- ✅ Technical decisions with lasting rationale
- ✅ API contracts and integration points
- ✅ Data models and schemas
- ✅ Configuration and extensibility points
- ✅ Testing strategies

## What to Exclude
- ❌ Task checklists and status updates
- ❌ Time estimates and completion percentages
- ❌ Temporary justifications ("we tried X but it didn't work")
- ❌ Implementation details that are obvious from code
- ❌ Step-by-step how-to guides (that's for code)
- ❌ Ephemeral decisions that don't affect future work

## Style
- Concise and scannable (Less but Better)
- Focus on "why" over "what" (code shows what)
- Explain trade-offs and context for decisions
- Use examples only when they clarify concepts
- Avoid redundancy with code/tests/README

# Output

After completion, confirm:
- Design doc(s) created/updated at `docs/design/[name].md`
- Design index updated at `docs/design/index.md`
- Task files moved from `docs/tasks/` to `docs/tasks-done/`
- Plan directory deleted: `docs/plan/[project-name]/`
- All changes committed via `/git`
