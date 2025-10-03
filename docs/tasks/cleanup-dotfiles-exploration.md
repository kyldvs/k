# Cleanup Dotfiles Exploration

## Description

Remove temporary files created during the explore-kyldvs-dotfiles task after
all integration tasks are complete. This cleanup task ensures no temporary
exploration artifacts remain in the repository.

## Prerequisites

**All integration tasks must be complete before running cleanup:**

- [ ] integrate-git-config.md (completed)
- [ ] integrate-tmux-config.md (completed)
- [ ] integrate-zsh-settings.md (completed)
- [ ] integrate-shell-aliases.md (completed)
- [ ] integrate-modern-cli-tools.md (completed)
- [ ] integrate-shell-integrations.md (completed)

**Additional prerequisites:**

- Working directory: `/mnt/kad/kyldvs/k`
- Verify no uncommitted work in progress in module/dotfiles/
- Confirm integration tasks completed successfully

## Step-by-Step Instructions

### 1. Verify Prerequisites

Ensure all integration tasks are complete:

```bash
# Check if integration tasks exist and are marked complete
ls -1 /mnt/kad/kyldvs/k/docs/tasks-done/integrate-*

# Verify expected completed tasks (should be 6 tasks)
ls -1 /mnt/kad/kyldvs/k/docs/tasks-done/integrate-* | wc -l
```

Expected: 6 integration tasks in tasks-done/ directory.

**If prerequisites not met:** Stop and complete remaining integration tasks
first.

### 2. Verify Cleanup Targets Exist

Before deletion, verify what will be removed:

```bash
# Check if module/dotfiles exists
ls -ld /mnt/kad/kyldvs/k/module/dotfiles

# Verify it's a git repository (shallow clone)
ls -ld /mnt/kad/kyldvs/k/module/dotfiles/.git

# Check assessment document
ls -l /mnt/kad/kyldvs/k/docs/dotfiles-assessment.md
```

Expected: Both directory and assessment document exist.

### 3. Verify No Uncommitted Work

Safety check to ensure nothing valuable will be lost:

```bash
# Check git status of module/dotfiles
cd /mnt/kad/kyldvs/k/module/dotfiles && git status

# Verify module/ is gitignored in parent repo
grep "^module/$" /mnt/kad/kyldvs/k/.gitignore
```

Expected:
- module/dotfiles/ has clean status or only untracked files (read-only)
- module/ appears in .gitignore

**Warning:** If module/dotfiles/ has modifications, investigate before
proceeding. The clone should never have been modified.

### 4. Remove Cloned Repository

```bash
# Remove the temporary clone
rm -rf /mnt/kad/kyldvs/k/module/dotfiles
```

Expected: No output, command succeeds silently.

### 5. Verify Deletion

```bash
# Confirm directory removed
ls /mnt/kad/kyldvs/k/module/dotfiles 2>&1
```

Expected: "No such file or directory" error.

### 6. Remove Empty module/ Directory (Optional)

If module/ directory is now empty, remove it:

```bash
# Check if module/ is empty
ls -A /mnt/kad/kyldvs/k/module/

# If empty, remove the directory
[ -z "$(ls -A /mnt/kad/kyldvs/k/module/)" ] && \
  rmdir /mnt/kad/kyldvs/k/module/
```

Expected: module/ directory removed if empty, or remains if other contents.

### 7. Handle Assessment Document

**Decision point:** Keep or remove dotfiles-assessment.md?

**Option A - Keep for Reference (Recommended):**

Move to docs/design/ for historical reference:

```bash
mv /mnt/kad/kyldvs/k/docs/dotfiles-assessment.md \
   /mnt/kad/kyldvs/k/docs/design/dotfiles-assessment.md
```

**Option B - Remove:**

```bash
rm /mnt/kad/kyldvs/k/docs/dotfiles-assessment.md
```

**Recommendation:** Keep the assessment document in docs/design/. It provides
valuable context for why certain configurations were integrated and what was
deliberately excluded. Future maintainers will benefit from this record.

### 8. Verify Git Status Clean

```bash
cd /mnt/kad/kyldvs/k && git status
```

Expected: module/ does not appear (gitignored). If assessment was moved to
docs/design/, it may appear as modified or new file (this is fine).

### 9. Commit Changes (If Assessment Moved)

If you moved the assessment document to docs/design/:

```bash
# Add and commit the moved assessment
cd /mnt/kad/kyldvs/k
just vcs cm "docs: archive dotfiles assessment to design docs"
just vcs push
```

Expected: Commit succeeds, assessment now in docs/design/.

### 10. Document Completion

Move this task to tasks-done/:

```bash
mv /mnt/kad/kyldvs/k/docs/tasks/cleanup-dotfiles-exploration.md \
   /mnt/kad/kyldvs/k/docs/tasks-done/
```

## Expected Outcomes

**Successful Completion Indicators:**

1. `/mnt/kad/kyldvs/k/module/dotfiles/` no longer exists
2. Assessment document either removed or moved to docs/design/
3. Git status clean (no unintended changes)
4. No errors during deletion
5. This task moved to tasks-done/

**Verification Checklist:**

- [ ] module/dotfiles/ removed successfully
- [ ] Assessment document handled (kept or removed)
- [ ] Git status shows no unexpected changes
- [ ] All integration tasks completed before cleanup
- [ ] No errors during any deletion operations

## Success Criteria

- [ ] Temporary clone completely removed
- [ ] No leftover exploration artifacts
- [ ] Git repository in clean state
- [ ] Assessment document preserved (if valuable) or removed (if not needed)
- [ ] Task marked complete and moved to tasks-done/

## Troubleshooting

**Issue:** module/dotfiles/ does not exist

**Solution:**
- Already cleaned up (success!)
- Or never created (explore task incomplete)
- Verify with: `ls -la /mnt/kad/kyldvs/k/module/`

**Issue:** Permission denied when removing directory

**Solution:**
```bash
# Check ownership and permissions
ls -ld /mnt/kad/kyldvs/k/module/dotfiles

# If needed, force removal
sudo rm -rf /mnt/kad/kyldvs/k/module/dotfiles
```

**Issue:** module/dotfiles/ has modified files

**Solution:**
- Should not happen (clone was read-only)
- Review changes: `cd /mnt/kad/kyldvs/k/module/dotfiles && git diff`
- If valuable, extract before deleting
- If accidental, safe to delete (integration already complete)

**Issue:** Uncertain whether to keep assessment document

**Solution:**
- Default: Keep in docs/design/ for historical reference
- Remove only if: all integration rationale documented elsewhere
- When in doubt, keep it (disk space is cheap, context is valuable)

**Issue:** Integration tasks not complete

**Solution:**
- Do not run cleanup yet
- Review integration task list
- Complete remaining tasks first
- Return to this cleanup task when ready

## Related Files

- module/dotfiles/ (removal target)
- docs/dotfiles-assessment.md (optional removal)
- docs/design/ (optional move target for assessment)
- .gitignore (ensures module/ ignored)

## Related Tasks

**Parent Task:**
- explore-kyldvs-dotfiles.md (created this cleanup task)

**Sibling Tasks (Prerequisites):**
- integrate-git-config.md
- integrate-tmux-config.md
- integrate-zsh-settings.md
- integrate-shell-aliases.md
- integrate-modern-cli-tools.md
- integrate-shell-integrations.md

## Priority

**Low** - Cleanup task with no blocking dependencies. Run after all
integrations complete. Delayed execution has no negative impact beyond minor
disk space usage.

## Estimated Effort

15-30 minutes. Simple deletion task with verification steps.

## Related Principles

- **#10 As Little Code as Possible**: Remove temporary artifacts; minimize
  what persists long-term
- **#9 Good Code is Sustainable**: Clean up after exploration; don't leave
  technical debt
- **#8 Good Code is Thorough**: Verify deletion success; handle edge cases
  (permissions, empty dirs)
- **#7 Good Code is Long-lasting**: Preserve assessment doc for future
  maintainers (historical context)

## Implementation Notes

**Safety Considerations:**

- Always verify path before `rm -rf` execution
- Clone is read-only shallow clone (safe to delete)
- No user data ever stored in module/dotfiles/
- Never modified during exploration (all work extracted to integration tasks)
- Complete all integrations first (irreversible deletion)

**Why Assessment Should Be Kept:**

The dotfiles-assessment.md document provides:
- Rationale for integration decisions
- Context on what was deliberately excluded
- Notes on adaptation choices
- Reference for future similar explorations
- Minimal storage cost, high informational value

Moving to docs/design/ archives it appropriately without losing this context.

**Post-Cleanup State:**

After successful cleanup:
- No trace of temporary clone remains
- Integration code persists in bootstrap system
- Assessment archived (recommended) or removed
- Clean git status
- Ready for next development phase
