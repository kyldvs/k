---
description: Create project specification from brief description
---

You will create a detailed project specification from the following input: $ARGUMENTS

# Process

1. **Extract Project Name**: Determine a suitable project name from the input. Use kebab-case format.

2. **Clarify Requirements**: If the description is vague or incomplete, ask targeted questions about:
   - Core functionality and features
   - User personas and use cases
   - Technical constraints or preferences
   - Integration requirements
   - Success criteria and acceptance tests
   - Scope boundaries (what's explicitly out of scope)

3. **Create Specification**: Generate a comprehensive spec at `docs/plan/[project-name]/spec.md` with:

4. **Commit Document**: After completing the specification, use `/git` to commit the spec document.

## Specification Template

```markdown
# [Project Name] - Specification

## Overview
Brief 2-3 sentence description of what this project does and why it exists.

## Goals
- Primary objective 1
- Primary objective 2
- Primary objective 3

## Requirements

### Functional Requirements
- FR-1: Specific user-facing functionality
- FR-2: Another functional requirement
- FR-3: ...

### Non-Functional Requirements
- NFR-1: Performance, security, or technical requirement
- NFR-2: ...

### Technical Requirements
- Specific technologies, libraries, or frameworks required
- Integration points with existing systems
- Platform or environment constraints

## User Stories / Use Cases
- As a [user type], I want [feature] so that [benefit]
- As a [user type], I can [action] to [outcome]

## Success Criteria
- Measurable outcome 1
- Measurable outcome 2
- Acceptance test criteria

## Constraints
- Technical limitations
- Time or resource constraints
- Compatibility requirements

## Non-Goals
Explicitly list what this project will NOT do:
- Out of scope feature 1
- Out of scope feature 2

## Assumptions
- Assumption 1 about the environment or users
- Assumption 2 about available resources

## Open Questions
- Question 1 that needs resolution
- Question 2 that may affect design
```

# Output

Create the specification file at the appropriate path and confirm:
- Project name derived
- Specification file created at `docs/plan/[project-name]/spec.md`
- Any clarifying questions that still need answers

# Style Guidelines

- Be specific and measurable
- Use active voice
- Avoid ambiguous terms like "fast", "user-friendly" without definition
- Separate must-haves from nice-to-haves
- Include rationale for key decisions
- Keep scope realistic and achievable
