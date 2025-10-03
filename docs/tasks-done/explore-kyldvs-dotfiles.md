# Explore kyldvs/dotfiles for VM Integration

## Description

One-time exploration of the kyldvs/dotfiles repository to identify
terminal-related configurations worth extracting and integrating into the VM
bootstrap system. After exploration, create child tasks for each valuable
configuration found.

## Prerequisites

- Working directory: `/mnt/kad/kyldvs/k`
- Git installed and configured
- Write access to docs/tasks/ directory
- .gitignore configured (module/ should be ignored)

## Scope

**In Scope (Terminal-Only):**
- Shell configurations (.bashrc, .zshrc, .profile, etc.)
- Development tool configs (git, vim, tmux, etc.)
- System setup scripts
- Package lists (terminal tools only)
- SSH configurations
- Terminal multiplexer configs
- Command-line utility configurations

**Out of Scope (GUI Tools):**
- Desktop environment configurations
- GUI application configs
- Window manager settings
- Any graphical tool configurations

## Step-by-Step Instructions

### 1. Verify .gitignore Configuration

```bash
# Ensure module/ directory is ignored
grep -q "^module/$" /mnt/kad/kyldvs/k/.gitignore || \
  echo "module/" >> /mnt/kad/kyldvs/k/.gitignore
```

Expected: No output if already present, or line added to .gitignore.

### 2. Create module/ Directory and Clone Repository

```bash
# Create directory
mkdir -p /mnt/kad/kyldvs/k/module

# Clone as read-only (shallow clone for exploration)
cd /mnt/kad/kyldvs/k/module
git clone --depth 1 git@github.com:kyldvs/dotfiles.git
```

Expected: Repository cloned to `/mnt/kad/kyldvs/k/module/dotfiles/`.

**Safety Check:** Verify you're in the correct directory:
```bash
pwd  # Should be: /mnt/kad/kyldvs/k/module
ls -la dotfiles/
```

### 3. Explore Repository Structure

```bash
# Navigate to cloned repo
cd /mnt/kad/kyldvs/k/module/dotfiles

# Get overview of repository structure
tree -L 2 -a || find . -maxdepth 2 -type d

# List all files to understand organization
find . -type f | sort
```

Document findings: Note directory structure and organization patterns.

### 4. Identify Terminal Configuration Files

Search for common terminal-related configuration files:

```bash
# Shell configurations
find . -name ".bashrc" -o -name ".zshrc" -o -name ".profile" \
  -o -name ".bash_profile" -o -name ".zprofile"

# Development tools
find . -name ".gitconfig" -o -name ".vimrc" -o -name ".tmux.conf" \
  -o -name ".inputrc"

# SSH configurations
find . -name "ssh_config" -o -name "sshd_config" -o -path "*/.ssh/*"

# Other configs
find . -name "*.conf" -o -name "*.rc" | grep -v ".git"
```

For each file found, examine its contents and assess value for VM bootstrap.

### 5. Examine Setup Scripts

```bash
# Find shell scripts
find . -name "*.sh" -type f

# Find installation or setup scripts
find . -name "*install*" -o -name "*setup*" -o -name "*bootstrap*"

# Check for package lists
find . -name "*packages*" -o -name "*deps*" -o -name "Brewfile" \
  -o -name "Aptfile"
```

For each script, review to identify:
- What it installs/configures
- Whether it's terminal-only
- Reusability for VM bootstrap

### 6. Create Assessment Document

Create a temporary assessment file to organize findings:

```bash
# Create assessment file (outside module/)
cat > /mnt/kad/kyldvs/k/docs/dotfiles-assessment.md << 'EOF'
# kyldvs/dotfiles Assessment

## Repository Structure
[Document directory organization]

## Valuable Configurations Found

### High Priority
[Configurations that should definitely be integrated]

### Medium Priority
[Nice-to-have configurations]

### Low Priority / Deferred
[Configurations that aren't worth the effort]

## Integration Notes
[Technical notes about how to integrate each configuration]

## Child Tasks to Create
[List of specific tasks to create via task-writer agent]
EOF
```

Populate this document as you explore.

### 7. Assess Each Configuration

For each configuration file found, document:

**Value Assessment:**
- Does it solve a real problem?
- Is it terminal-only (not GUI)?
- Would it benefit the VM environment?
- Is it maintainable long-term?

**Integration Complexity:**
- Simple copy/symlink?
- Requires adaptation?
- Has dependencies?
- Needs testing infrastructure?

**Priority Rating:**
- High: Critical for productivity, low complexity
- Medium: Useful but not critical, or moderate complexity
- Low: Nice-to-have, high complexity, or niche use case

### 8. Create Child Tasks via task-writer Agent

For each high/medium priority configuration, invoke the task-writer agent:

**Example for shell configuration:**
```
@task-writer

Create a task definition for integrating zsh configuration from kyldvs/dotfiles
into the VM bootstrap system.

Context:
- File location: module/dotfiles/.zshrc
- Target: bootstrap/vm.sh
- Contains: [describe key features - aliases, functions, prompt, etc.]
- Integration approach: [copy, adapt, or create new component]
- Dependencies: [zsh, any plugins]
- Priority: High
```

**Repeat for each valuable configuration identified.**

Document in assessment file which child tasks were created.

### 9. Create Cleanup Child Task

Create a final child task for cleanup:

```
@task-writer

Create a task definition for cleaning up the temporary kyldvs/dotfiles
exploration clone.

Context:
- Remove: /mnt/kad/kyldvs/k/module/dotfiles/
- May also remove: /mnt/kad/kyldvs/k/docs/dotfiles-assessment.md
  (if no longer needed)
- Should only run after all integration child tasks are complete
- Simple deletion task
```

### 10. Document Completion

Update this task document to mark it complete:

```bash
# Move to tasks-done/
mv /mnt/kad/kyldvs/k/docs/tasks/explore-kyldvs-dotfiles.md \
   /mnt/kad/kyldvs/k/docs/tasks-done/
```

## Expected Outcomes

**Successful Completion Indicators:**

1. Repository cloned to `/mnt/kad/kyldvs/k/module/dotfiles/`
2. Assessment document created in `/mnt/kad/kyldvs/k/docs/dotfiles-assessment.md`
3. All configurations reviewed and categorized by priority
4. Child tasks created in `/mnt/kad/kyldvs/k/docs/tasks/` for each
   valuable configuration
5. Cleanup child task created
6. This parent task moved to `/mnt/kad/kyldvs/k/docs/tasks-done/`

**Verification Checklist:**

- [ ] module/dotfiles/ exists and contains cloned repo
- [ ] Assessment document exists with complete findings
- [ ] At least one child task created for integration
- [ ] Cleanup child task created
- [ ] All child tasks follow established patterns
- [ ] No modifications made to kyldvs/dotfiles (read-only)

## Success Criteria

- [ ] kyldvs/dotfiles cloned to correct location
- [ ] All terminal-related configs identified and assessed
- [ ] High/medium priority configs have child tasks created
- [ ] Cleanup child task exists
- [ ] Assessment document provides clear integration roadmap
- [ ] No GUI-related configurations included
- [ ] Clone is truly isolated (no push capability verified)

## Troubleshooting

**Issue:** Cannot clone repository (permission denied)

**Solution:**
- Verify SSH key is configured: `ssh -T git@github.com`
- Try HTTPS instead: `git clone --depth 1 https://github.com/kyldvs/dotfiles.git`
- Ensure you have read access to the repository

**Issue:** module/ directory tracked by git

**Solution:**
- Verify .gitignore: `grep "^module/$" /mnt/kad/kyldvs/k/.gitignore`
- Check status: `git status /mnt/kad/kyldvs/k/module/`
- If tracked, add to .gitignore and run: `git rm -r --cached module/`

**Issue:** Cloned wrong repository

**Solution:**
- Remove incorrect clone: `rm -rf /mnt/kad/kyldvs/k/module/dotfiles`
- Verify you're in correct directory: `pwd`
- Clone again with correct URL

**Issue:** Too many configurations found (overwhelmed)

**Solution:**
- Start with obvious wins: .zshrc, .gitconfig, .tmux.conf
- Create child tasks for high-priority items first
- Medium/low priority can be deferred or ignored
- Remember: "Less but Better" - only integrate what truly adds value

## Related Files

- bootstrap/vm.sh (target for integrations)
- bootstrap/lib/steps/ (component library)
- bootstrap/manifests/vm.txt (build manifest)
- docs/tasks/vm-user-bootstrap.md (parent VM provisioning task)
- .gitignore (must ignore module/)

## Related Tasks

This task creates child tasks. Child tasks will integrate into:
- vm-user-bootstrap.md (main VM provisioning task)

## Priority

**Medium** - Informs VM bootstrap implementation but not blocking. Should be
completed before implementing vm-user-bootstrap.md to ensure we're building
on solid foundation rather than reinventing configurations.

## Estimated Effort

2-4 hours for exploration and child task creation. Actual integration effort
depends on number of child tasks created.

## Related Principles

- **#2 Good Code is Useful**: Focus on configurations that solve real
  problems, not theoretical improvements
- **#10 As Little Code as Possible**: Only integrate configs that truly add
  value; skip nice-to-haves
- **#4 Good Code is Understandable**: Document findings clearly so child
  tasks have proper context
- **#8 Good Code is Thorough**: Systematically explore all terminal configs;
  handle edge cases in child tasks

## Implementation Notes

**Isolation Strategy:**
- Clone is read-only (--depth 1, no push capability)
- Located in module/ (gitignored)
- Temporary by design (cleanup child task removes it)
- Never modify original kyldvs/dotfiles

**Child Task Guidelines:**
- Each child task should be independently implementable
- Provide full context from this exploration
- Include specific file paths and integration approach
- Estimate effort honestly
- Assign appropriate priority

**Integration Philosophy:**
Following "Less but Better":
- Prefer adapting over copying wholesale
- Extract principles, not just files
- Consider maintenance burden
- Question whether each config truly needs to exist
- Optimize for the common case (VM development environment)

**Decision Framework for Each Config:**
1. Does it solve a problem VM users will actually encounter?
2. Is the benefit worth the maintenance cost?
3. Can it be simpler?
4. Will it age well?

If you can't answer "yes" to all four, consider deferring or skipping.
