# Explore kyldvs/dotfiles - Implementation Plan

## Prerequisites
- Git installed and configured with SSH access to github.com/kyldvs/dotfiles
- Write access to `/mnt/kad/kyldvs/k/docs/tasks/` directory
- Working directory: `/mnt/kad/kyldvs/k`
- task-writer agent available for creating child tasks

## Architecture Overview
This is a discovery task that doesn't modify code, but instead creates a structured assessment and child tasks for future implementation. The workflow:

1. Clone repository to temporary location (`module/dotfiles/`)
2. Explore and catalog configurations
3. Assess each configuration (value, complexity, priority)
4. Document findings in assessment document
5. Create child task definitions via task-writer agent
6. Clean up by moving this task to completed

**Key Files:**
- `.gitignore` - Must include `module/` entry
- `module/dotfiles/` - Temporary clone location (gitignored)
- `docs/dotfiles-assessment.md` - Assessment document (output)
- `docs/tasks/*.md` - Child task definitions (output)
- `docs/tasks-done/explore-kyldvs-dotfiles.md` - This task after completion

**Integration Points:**
- Child tasks will eventually modify: `bootstrap/vm.sh`, `bootstrap/lib/steps/`, `bootstrap/manifests/vm.txt`

## Task Breakdown

### Phase 1: Setup and Isolation
- [ ] Task 1.1: Verify .gitignore includes module/
  - Files: `.gitignore`
  - Dependencies: None
  - Details: Check if `module/` entry exists, add if missing

- [ ] Task 1.2: Create module/ directory
  - Files: `module/` (directory)
  - Dependencies: Task 1.1
  - Details: `mkdir -p /mnt/kad/kyldvs/k/module`

- [ ] Task 1.3: Clone kyldvs/dotfiles repository
  - Files: `module/dotfiles/` (cloned repo)
  - Dependencies: Task 1.2
  - Details: `git clone --depth 1 git@github.com:kyldvs/dotfiles.git` (shallow clone, read-only)
  - Error handling: If SSH fails, provide HTTPS fallback option

- [ ] Task 1.4: Verify clone is isolated
  - Files: `module/dotfiles/.git/`
  - Dependencies: Task 1.3
  - Details: Confirm no push capability, verify gitignore status

### Phase 2: Repository Exploration
- [ ] Task 2.1: Map repository structure
  - Files: `module/dotfiles/`
  - Dependencies: Task 1.4
  - Details: Run `tree -L 2 -a` or `find . -maxdepth 2 -type d` to understand organization

- [ ] Task 2.2: Identify shell configurations
  - Files: Search for `.bashrc`, `.zshrc`, `.profile`, `.bash_profile`, `.zprofile`
  - Dependencies: Task 2.1
  - Details: `find . -name ".bashrc" -o -name ".zshrc" -o -name ".profile" -o -name ".bash_profile" -o -name ".zprofile"`

- [ ] Task 2.3: Identify development tool configs
  - Files: Search for `.gitconfig`, `.vimrc`, `.tmux.conf`, `.inputrc`
  - Dependencies: Task 2.1
  - Details: `find . -name ".gitconfig" -o -name ".vimrc" -o -name ".tmux.conf" -o -name ".inputrc"`

- [ ] Task 2.4: Identify SSH configurations
  - Files: Search for `ssh_config`, `sshd_config`, `.ssh/*`
  - Dependencies: Task 2.1
  - Details: `find . -name "ssh_config" -o -name "sshd_config" -o -path "*/.ssh/*"`

- [ ] Task 2.5: Identify setup scripts and package lists
  - Files: Search for `*.sh`, `*install*`, `*setup*`, `*bootstrap*`, `*packages*`, `Brewfile`, `Aptfile`
  - Dependencies: Task 2.1
  - Details: Multiple find commands for different patterns

- [ ] Task 2.6: Identify other terminal configs
  - Files: Search for `*.conf`, `*.rc` (excluding .git)
  - Dependencies: Task 2.1
  - Details: `find . -name "*.conf" -o -name "*.rc" | grep -v ".git"`

### Phase 3: Assessment Document Creation
- [ ] Task 3.1: Create assessment document structure
  - Files: `docs/dotfiles-assessment.md`
  - Dependencies: Task 2.6 (exploration complete)
  - Details: Create document with sections: Repository Structure, Valuable Configurations (High/Medium/Low Priority), Integration Notes, Child Tasks to Create

- [ ] Task 3.2: Document repository structure
  - Files: `docs/dotfiles-assessment.md`
  - Dependencies: Task 3.1
  - Details: Summarize directory organization and patterns found

- [ ] Task 3.3: Assess each configuration file
  - Files: `docs/dotfiles-assessment.md`
  - Dependencies: Task 3.2
  - Details: For each file found in Phase 2, apply assessment criteria:
    - Value: Solves real problem? Terminal-only? Benefits VM? Maintainable?
    - Complexity: Simple copy? Needs adaptation? Has dependencies?
    - Priority: High/Medium/Low based on above
  - Implementation: Read each config file, understand its purpose, document assessment

### Phase 4: Child Task Creation
- [ ] Task 4.1: Create child tasks for high-priority configurations
  - Files: `docs/tasks/*.md` (multiple child tasks)
  - Dependencies: Task 3.3
  - Details: For each high-priority config, invoke task-writer agent with context:
    - File location in dotfiles
    - Integration target (bootstrap/vm.sh or lib/steps/)
    - Key features to integrate
    - Dependencies required
    - Integration approach (copy/adapt/new component)
  - Delegation: Use task-writer agent for each child task

- [ ] Task 4.2: Create child tasks for medium-priority configurations
  - Files: `docs/tasks/*.md` (multiple child tasks)
  - Dependencies: Task 4.1
  - Details: Same as 4.1 but for medium-priority items
  - Delegation: Use task-writer agent for each child task

- [ ] Task 4.3: Document deferred low-priority configurations
  - Files: `docs/dotfiles-assessment.md`
  - Dependencies: Task 4.2
  - Details: List low-priority items with rationale for deferral

- [ ] Task 4.4: Create cleanup child task
  - Files: `docs/tasks/cleanup-dotfiles-exploration.md`
  - Dependencies: Task 4.3
  - Details: Use task-writer agent to create task for removing `module/dotfiles/` and optionally `docs/dotfiles-assessment.md`

- [ ] Task 4.5: Document created child tasks in assessment
  - Files: `docs/dotfiles-assessment.md`
  - Dependencies: Task 4.4
  - Details: List all created child task files in "Child Tasks to Create" section

### Phase 5: Completion
- [ ] Task 5.1: Review assessment document
  - Files: `docs/dotfiles-assessment.md`
  - Dependencies: Task 4.5
  - Details: Verify completeness, clarity, and actionability

- [ ] Task 5.2: Verify success criteria
  - Files: Multiple files from success criteria
  - Dependencies: Task 5.1
  - Details: Check all success criteria from spec.md:
    - Repository cloned to correct location
    - Assessment document exists and is complete
    - At least one child task created (or explicit "none found")
    - Cleanup child task exists
    - Child tasks follow patterns
    - No modifications to dotfiles repo

- [ ] Task 5.3: Move task to tasks-done/
  - Files: `docs/tasks-done/explore-kyldvs-dotfiles.md`
  - Dependencies: Task 5.2
  - Details: `mv docs/tasks/explore-kyldvs-dotfiles.md docs/tasks-done/`

## Files to Create
- `module/` - Directory for temporary clone
- `module/dotfiles/` - Cloned repository (temporary)
- `docs/dotfiles-assessment.md` - Assessment document with findings
- `docs/tasks/integrate-*.md` - Child task definitions (number depends on findings)
- `docs/tasks/cleanup-dotfiles-exploration.md` - Cleanup child task

## Files to Modify
- `.gitignore` - Add `module/` entry if not present

## Files to Move
- `docs/tasks/explore-kyldvs-dotfiles.md` → `docs/tasks-done/explore-kyldvs-dotfiles.md`

## Assessment Framework

For each configuration file discovered, apply this framework:

**Value Assessment (must answer "yes" to all):**
1. Does it solve a problem VM users will actually encounter?
2. Is it terminal-only (not GUI)?
3. Would it benefit the VM development environment?
4. Is it maintainable long-term?

**Integration Complexity:**
- Simple: Direct copy or minimal adaptation
- Moderate: Requires adaptation or has few dependencies
- Complex: Heavy dependencies or significant rework needed

**Priority Assignment:**
- **High**: Critical for productivity + (simple or moderate complexity)
- **Medium**: Useful but not critical + moderate complexity, OR very useful + complex
- **Low**: Nice-to-have + any complexity, OR any value + very complex

**Decision Rule:**
Only create child tasks for High and Medium priority. Document Low priority items but do not create tasks.

## Testing Strategy
No automated tests required for this exploration task. Manual verification:

1. Verify clone location: `ls -la /mnt/kad/kyldvs/k/module/dotfiles/`
2. Verify gitignore: `git status /mnt/kad/kyldvs/k/module/` (should not be tracked)
3. Verify assessment exists: `cat /mnt/kad/kyldvs/k/docs/dotfiles-assessment.md`
4. Verify child tasks exist: `ls /mnt/kad/kyldvs/k/docs/tasks/integrate-*.md`
5. Verify cleanup task exists: `cat /mnt/kad/kyldvs/k/docs/tasks/cleanup-dotfiles-exploration.md`
6. Verify no modifications to dotfiles: `cd /mnt/kad/kyldvs/k/module/dotfiles && git status` (should be clean)
7. Verify task moved: `ls /mnt/kad/kyldvs/k/docs/tasks-done/explore-kyldvs-dotfiles.md`

## Risk Assessment

**Risk 1: SSH authentication failure when cloning**
- Mitigation: Provide HTTPS fallback URL in error handling
- Impact: Low - easy to recover with alternative method

**Risk 2: module/ directory accidentally committed**
- Mitigation: Verify .gitignore before cloning (Task 1.1)
- Impact: Medium - would bloat repository, but easily fixed with `git rm -r --cached`

**Risk 3: Too many configurations found (overwhelmed)**
- Mitigation: Apply "Less but Better" philosophy strictly - be aggressive about priority ratings
- Impact: Low - can defer many items to low priority
- Guideline: Prefer 3-5 high-priority integrations over 20+ tasks

**Risk 4: No valuable configurations found**
- Mitigation: Document explicitly in assessment that no integrations recommended
- Impact: Low - valid outcome, task still successful if properly documented

**Risk 5: Modifications accidentally made to dotfiles repo**
- Mitigation: Verify read-only status after clone (Task 1.4)
- Impact: Low - clone is shallow and temporary, worst case is re-clone

**Risk 6: Task-writer agent unavailable**
- Mitigation: Create child tasks manually using existing task patterns as templates
- Impact: Low - more manual work but same outcome

## Notes

**Important Considerations:**
- This is a one-time exploration task - not meant to be repeated
- Assessment quality is more important than speed - take time to understand each config
- Child tasks should be independently implementable without re-exploring dotfiles
- Follow "Less but Better" ruthlessly - when in doubt, rate as low priority
- Prefer adapting/extracting principles over wholesale copying
- Consider maintenance burden - every integration is code to maintain forever

**Potential Gotchas:**
- macOS-specific configs in dotfiles (skip these for Linux VM)
- GUI tool configs mixed with terminal configs (carefully filter)
- Deprecated or legacy configurations (assess if still relevant)
- Personal preferences vs broadly useful configurations (prefer latter)

**Performance Considerations:**
- Shallow clone (--depth 1) for faster cloning and smaller disk usage
- Exploration is manual and interactive - no performance concerns

**Integration Philosophy:**
Per "Less but Better" principles:
- Only integrate what solves actual problems
- Extract principles, not just copy files
- Question whether each config truly needs to exist
- Optimize for the common case (VM development environment)
- When in doubt, skip it

**Expected Outcomes:**
Based on common dotfiles patterns, likely to find:
- High priority: .gitconfig, .zshrc or .bashrc, .tmux.conf (if used)
- Medium priority: .vimrc, SSH client config, shell aliases/functions
- Low priority: Niche tool configs, macOS-specific items, GUI configs

Realistic target: 3-5 high-priority child tasks, 2-4 medium-priority tasks, remainder documented as low-priority/deferred.
