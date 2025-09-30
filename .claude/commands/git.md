---
description: Git commit and push workflow with pre-commit hooks
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(just vcs acp:*)
---

Changes are complete. Time to commit and push.

## Quick Workflow

**ALWAYS use:** `just vcs acp "commit message"`

This handles add, commit, and push in one command with pre-commit hooks.

## Pre-Commit Checklist

1. **Run tests if not already done:**
   ```bash
   just test all
   ```

2. **Pre-commit hooks will run automatically:**
   - Linting
   - Formatting checks
   - Build validation

## Commit Message Format

Conventional commits: `type: description`

**Types:**
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `test:` - Test changes
- `refactor:` - Code refactoring
- `chore:` - Build/config changes

**Examples:**
```bash
just vcs acp "feat: add git installation to bootstrap"
just vcs acp "fix: correct idempotency check in init-k"
just vcs acp "docs: update CLAUDE.md with new patterns"
just vcs acp "refactor: improve platform dispatch pattern"
```

## Analysis Phase

Before committing, analyze changes:

```bash
git status              # See all changes
git diff               # Review unstaged changes
git diff --staged      # Review staged changes
git log --oneline -5   # Recent commits for context
```

## Documentation Considerations

**Rarely needed** - Most changes don't require documentation updates.

### When to update CLAUDE.md:
- ✅ New core patterns or conventions
- ✅ Major architectural changes
- ✅ Critical workflow modifications

### When NOT to update CLAUDE.md:
- ❌ Individual feature additions
- ❌ Bug fixes
- ❌ Obvious patterns
- ❌ Most changes (90%+)

**Rule:** No proactive documentation unless explicitly requested.

## Manual Workflow (if needed)

For specific staging or multi-step commits:

```bash
git add <files>
git commit -m "type: description"
git push
```

## Key Reminders

- Run tests before committing (`just test all`)
- Single-line commit messages only
- Atomic commits (one logical change per commit)
- Pre-commit hooks run linting automatically
- Documentation updates are rare
