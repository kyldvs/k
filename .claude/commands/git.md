---
description: Git commit and push workflow with pre-commit hooks
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(just vcs cm:*), Bash(just vcs push:*)
---

Changes are complete. Time to commit and push.

## Quick Workflow

**Two-step workflow:**
1. `just vcs cm "commit message"` - Add and commit
2. `just vcs push` - Push to remote

**Or combine:** `just vcs cm "commit message" && just vcs push`

Pre-commit hooks run automatically during commit.

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
just vcs cm "feat: add git installation to bootstrap" && just vcs push
just vcs cm "fix: correct idempotency check in init-k" && just vcs push
just vcs cm "docs: update CLAUDE.md with new patterns" && just vcs push
just vcs cm "refactor: improve platform dispatch pattern" && just vcs push
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
