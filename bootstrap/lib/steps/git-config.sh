# Configure Git with sensible defaults for development workflow
#
# This component applies 8 Git configuration settings that improve day-to-day
# development experience by eliminating common pain points and providing better
# defaults than Git's out-of-the-box configuration.
#
# Configuration Settings Applied:
#
# 1. push.default = current
#    Eliminates "fatal: The current branch has no upstream branch" errors.
#    Pushes current branch to remote branch with same name without requiring
#    explicit upstream configuration.
#
# 2. pull.ff = true
#    Prevents unexpected merge commits on pull. Only allows fast-forward pulls,
#    keeping history clean and predictable.
#
# 3. merge.ff = true
#    Fast-forwards when possible during merges, avoiding unnecessary merge
#    commits and maintaining cleaner history.
#
# 4. merge.conflictstyle = zdiff3
#    Shows common ancestor context during merge conflicts, making conflict
#    resolution significantly clearer and easier to understand.
#
# 5. init.defaultBranch = main
#    Sets modern default branch name, aligning with GitHub and industry
#    conventions.
#
# 6. diff.algorithm = histogram
#    Provides more intuitive and readable diffs with better move detection
#    compared to default Myers algorithm.
#
# 7. log.date = iso
#    Uses ISO 8601 timestamp format (YYYY-MM-DD HH:MM:SS) for consistent,
#    parseable, and internationally standard date display.
#
# 8. core.autocrlf = false
#    Prevents automatic line ending conversion on Linux/Unix systems, avoiding
#    cross-platform line ending issues.
#
# Identity Preservation:
# - Preserves existing user.name and user.email values if present
# - Only configures workflow settings, never touches user identity
#
# Idempotency:
# - Safe to run multiple times
# - Skips if configuration already applied (checks merge.conflictstyle)
# - No destructive overwrites of user customizations beyond these 8 settings

configure_git() {
  kd_step_start "git-config" "Configuring Git with sensible defaults"

  # Check if git is installed
  if ! command -v git >/dev/null 2>&1; then
    kd_error "Git is not installed"
    return 1
  fi

  # Check if already configured (idempotency)
  current_conflictstyle=$(git config --global --get merge.conflictstyle 2>/dev/null || echo "")
  if [ "$current_conflictstyle" = "zdiff3" ]; then
    kd_step_skip "Git already configured with sensible defaults"
    return 0
  fi

  kd_log "Applying Git configuration settings"

  # Preserve existing user identity
  user_name=$(git config --global --get user.name 2>/dev/null || echo "")
  user_email=$(git config --global --get user.email 2>/dev/null || echo "")

  # Apply configuration settings
  kd_log "Setting push.default = current"
  git config --global push.default current || return 1

  kd_log "Setting pull.ff = true"
  git config --global pull.ff true || return 1

  kd_log "Setting merge.ff = true"
  git config --global merge.ff true || return 1

  kd_log "Setting merge.conflictstyle = zdiff3"
  git config --global merge.conflictstyle zdiff3 || return 1

  kd_log "Setting init.defaultBranch = main"
  git config --global init.defaultBranch main || return 1

  kd_log "Setting diff.algorithm = histogram"
  git config --global diff.algorithm histogram || return 1

  kd_log "Setting log.date = iso"
  git config --global log.date iso || return 1

  kd_log "Setting core.autocrlf = false"
  git config --global core.autocrlf false || return 1

  # Restore user identity if it existed
  if [ -n "$user_name" ]; then
    kd_log "Restoring user.name"
    git config --global user.name "$user_name" || return 1
  fi

  if [ -n "$user_email" ]; then
    kd_log "Restoring user.email"
    git config --global user.email "$user_email" || return 1
  fi

  kd_step_end
}
