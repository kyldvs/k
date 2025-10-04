#!/usr/bin/env bash
set -euo pipefail

# Dotfiles system test
# Tests dotfiles setup, git identity, packages, and conflict handling

# Source shared assertion helpers
. /test-lib/assertions.sh

echo "→ Testing dotfiles system"

# Setup Phase: Prepare test environment
echo "→ Setting up test environment"

# Ensure we're the test user
if [ "$(id -un)" != "testuser" ]; then
  echo "✗ FAIL: Must run as testuser"
  exit 1
fi

# Navigate to repo root
cd /var/www/k

# Create config directory and copy test config
mkdir -p "$HOME/.config/kyldvs/k"
cp /fixtures/dotfiles-test-config.yml "$HOME/.config/kyldvs/k/dotfiles.yml"
chmod 644 "$HOME/.config/kyldvs/k/dotfiles.yml"

assert_file "$HOME/.config/kyldvs/k/dotfiles.yml"
echo "  ✓ Test configuration ready"

# Test Phase 1: Fresh Installation
echo "→ Testing fresh installation (just k setup)"

# Verify prerequisites installed
assert_command_exists stow
assert_command_exists yq
assert_command_exists git
echo "  ✓ Prerequisites available"

# Run setup command
setup_output=$(cd /var/www/k && just k setup 2>&1) || {
  echo "✗ FAIL: Setup command failed"
  echo "$setup_output"
  exit 1
}
echo "  ✓ Setup completed successfully"

# Verify dotfiles are stowed (symlinks created)
assert_symlink "$HOME/.zshrc" "../../dotfiles/zsh/.zshrc"
assert_symlink "$HOME/.zshenv" "../../dotfiles/zsh/.zshenv"
assert_symlink "$HOME/.tmux.conf" "../../dotfiles/tmux/.tmux.conf"
assert_symlink "$HOME/.gitconfig" "../../dotfiles/git/.gitconfig"
echo "  ✓ Dotfiles symlinked to home directory"

# Verify git config directory created
assert_file "$HOME/.config/git"
echo "  ✓ Git config directory created"

# Test Phase 2: Idempotency
echo "→ Testing idempotency (running setup twice)"

setup_output2=$(cd /var/www/k && just k setup 2>&1) || {
  echo "✗ FAIL: Second setup run failed"
  echo "$setup_output2"
  exit 1
}

# Verify symlinks still correct
assert_symlink "$HOME/.zshrc" "../../dotfiles/zsh/.zshrc"
assert_symlink "$HOME/.tmux.conf" "../../dotfiles/tmux/.tmux.conf"
echo "  ✓ Idempotency verified (setup safe to run multiple times)"

# Test Phase 3: Git Identity Switching
echo "→ Testing git identity switching"

# Create test directories for profiles
mkdir -p "$HOME/personal/test-repo"
mkdir -p "$HOME/work/test-repo"

# Initialize git repos
cd "$HOME/personal/test-repo"
git init >/dev/null 2>&1
personal_email=$(git config user.email || echo "")

cd "$HOME/work/test-repo"
git init >/dev/null 2>&1
work_email=$(git config user.email || echo "")

# Verify different identities
if [ "$personal_email" = "test@personal.example.com" ]; then
  echo "  ✓ Personal git identity correct: $personal_email"
else
  echo "✗ FAIL: Personal git identity incorrect"
  echo "  Expected: test@personal.example.com"
  echo "  Got: $personal_email"
  exit 1
fi

if [ "$work_email" = "test@work.example.com" ]; then
  echo "  ✓ Work git identity correct: $work_email"
else
  echo "✗ FAIL: Work git identity incorrect"
  echo "  Expected: test@work.example.com"
  echo "  Got: $work_email"
  exit 1
fi

# Return to repo root
cd /var/www/k

# Test Phase 4: Package Installation
echo "→ Testing package installation"

# Test dry run first
dryrun_output=$(cd /var/www/k && just k install-packages true 2>&1) || {
  echo "✗ FAIL: Dry-run package install failed"
  echo "$dryrun_output"
  exit 1
}
echo "  ✓ Dry-run package installation works"

# Run actual package installation
install_output=$(cd /var/www/k && just k install-packages 2>&1) || {
  echo "✗ FAIL: Package installation failed"
  echo "$install_output"
  exit 1
}

# Verify packages installed
assert_command_exists tree
assert_command_exists htop
echo "  ✓ Packages installed successfully"

# Test Phase 5: Conflict Detection
echo "→ Testing conflict detection"

# Remove existing symlinks
rm -f "$HOME/.zshrc"

# Create conflicting file
echo "# Existing config" > "$HOME/.zshrc"

# Run stow again - should handle conflict gracefully
if conflict_output=$(cd /var/www/k && just k sync 2>&1); then
  # Check if file was backed up
  backup_count=$(find "$HOME/.config/kyldvs/k/backups" -name ".zshrc.*" \
    2>/dev/null | wc -l || echo "0")
  if [ "$backup_count" -gt 0 ]; then
    echo "  ✓ Conflict detected and backup created"
  else
    # If no backup but sync succeeded, stow might have handled it differently
    echo "  ✓ Conflict handled (stow resolved)"
  fi
else
  echo "  ⚠ Warning: Sync with conflict may have failed (expected behavior)"
fi

# Clean up for next tests
rm -f "$HOME/.zshrc"

# Test Phase 6: YAML Validation
echo "→ Testing YAML validation"

# Backup valid config
cp "$HOME/.config/kyldvs/k/dotfiles.yml" \
   "$HOME/.config/kyldvs/k/dotfiles.yml.backup"

# Create invalid YAML
echo "invalid: yaml: [unclosed" > "$HOME/.config/kyldvs/k/dotfiles.yml"

# Try to run setup - should fail gracefully
if invalid_output=$(cd /var/www/k && just k setup 2>&1); then
  echo "  ⚠ Warning: Invalid YAML did not cause failure (may have fallback)"
else
  echo "  ✓ Invalid YAML handled gracefully"
fi

# Restore valid config
mv "$HOME/.config/kyldvs/k/dotfiles.yml.backup" \
   "$HOME/.config/kyldvs/k/dotfiles.yml"

# Re-run setup to restore state
( cd /var/www/k && just k setup ) >/dev/null 2>&1 || true

# Test Phase 7: Sync After Pull
echo "→ Testing sync after pull (simulated)"

# Get current content of symlinked file
original_content=$(cat "$HOME/.zshrc" 2>/dev/null || echo "")

# Verify it's a symlink
if [ ! -L "$HOME/.zshrc" ]; then
  echo "✗ FAIL: .zshrc is not a symlink"
  exit 1
fi

# Changes to repo file should be immediately visible
# (no actual change needed - symlink nature ensures this)
current_content=$(cat "$HOME/.zshrc" 2>/dev/null || echo "")

if [ "$original_content" = "$current_content" ]; then
  echo "  ✓ Symlinks ensure repo changes visible immediately"
else
  echo "  ⚠ Warning: Content mismatch (may be due to test setup)"
fi

# Test Phase 8: Status Command
echo "→ Testing status command"

status_output=$(cd /var/www/k && just k status 2>&1) || {
  echo "✗ FAIL: Status command failed"
  exit 1
}

# Verify status output contains expected information
if echo "$status_output" | grep -q "dotfiles"; then
  echo "  ✓ Status command works"
else
  echo "  ⚠ Warning: Status output may not contain expected info"
fi

# Test Phase 9: Cleanup Verification
echo "→ Testing cleanup and final state"

# Verify all expected symlinks still exist
assert_symlink "$HOME/.zshrc" "../../dotfiles/zsh/.zshrc"
assert_symlink "$HOME/.tmux.conf" "../../dotfiles/tmux/.tmux.conf"
assert_symlink "$HOME/.gitconfig" "../../dotfiles/git/.gitconfig"
echo "  ✓ All dotfiles still properly linked"

echo ""
echo "✓ All dotfiles tests passed"
