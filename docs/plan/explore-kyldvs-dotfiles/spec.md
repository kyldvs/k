# Explore kyldvs/dotfiles - Specification

## Overview
One-time exploration task to analyze the kyldvs/dotfiles repository, identify terminal-related configurations worth integrating into the VM bootstrap system, and create child tasks for each valuable configuration found. This is a discovery and planning task, not an implementation task.

## Goals
- Systematically explore the kyldvs/dotfiles repository to inventory all terminal-related configurations
- Assess each configuration for value and integration complexity
- Create focused child tasks for integrating high-value configurations into the VM bootstrap system
- Establish a clear integration roadmap without actually implementing any integrations

## Requirements

### Functional Requirements
- FR-1: Clone kyldvs/dotfiles repository as read-only (shallow clone) to `/mnt/kad/kyldvs/k/module/dotfiles/`
- FR-2: Identify all terminal-related configuration files (shell configs, development tools, system scripts, SSH configs, terminal multiplexer configs)
- FR-3: Exclude GUI-related configurations from assessment (desktop environments, window managers, graphical tools)
- FR-4: Assess each configuration for value, integration complexity, and priority (High/Medium/Low)
- FR-5: Create assessment document at `/mnt/kad/kyldvs/k/docs/dotfiles-assessment.md` documenting findings
- FR-6: Create child task definitions using task-writer agent for each high/medium priority configuration
- FR-7: Create cleanup child task for removing the temporary clone after integration tasks complete
- FR-8: Move this task to `docs/tasks-done/` upon completion

### Non-Functional Requirements
- NFR-1: Clone must be isolated (no push capability, located in gitignored module/ directory)
- NFR-2: Clone must be temporary by design (cleanup task should remove it)
- NFR-3: Never modify the original kyldvs/dotfiles repository
- NFR-4: Assessment must follow "Less but Better" philosophy - only recommend integrations that solve real problems
- NFR-5: Child tasks must be independently implementable with full context

### Technical Requirements
- Git installed and configured with SSH access to github.com/kyldvs/dotfiles
- Write access to docs/tasks/ directory
- .gitignore must include `module/` entry
- Working directory: `/mnt/kad/kyldvs/k`
- Target integration points: bootstrap/vm.sh, bootstrap/lib/steps/, bootstrap/manifests/vm.txt

## User Stories / Use Cases
- As a developer, I want to identify valuable configurations from my existing dotfiles so that I can systematically integrate them into the VM bootstrap
- As a developer, I want each configuration assessed independently so that I can prioritize integration work
- As a developer, I want child tasks created with full context so that I can implement integrations without re-exploring the source repository
- As a developer, I want GUI configurations excluded so that I focus only on terminal-relevant tools for the VM environment

## Success Criteria
- Repository cloned successfully to `/mnt/kad/kyldvs/k/module/dotfiles/`
- Assessment document created with complete findings organized by priority
- At least one child task created for integration (or explicit documentation that no valuable configs found)
- Cleanup child task created
- All child tasks follow established task documentation patterns
- No modifications made to kyldvs/dotfiles (read-only verified)
- This task moved to `docs/tasks-done/`

## Constraints
- Must be terminal-only: exclude all GUI-related configurations
- Must maintain isolation: clone is read-only and temporary
- Must follow "Less but Better": only recommend integrations that truly add value
- Time constraint: 2-4 hours for exploration and child task creation
- Should complete before vm-user-bootstrap.md implementation begins

## Non-Goals
- This task does NOT implement any integrations - only creates tasks for them
- Does NOT modify kyldvs/dotfiles repository
- Does NOT integrate GUI configurations
- Does NOT create permanent storage of the cloned repository
- Does NOT implement VM bootstrap changes directly

## Assumptions
- SSH key configured for github.com access
- kyldvs/dotfiles repository contains terminal-related configurations worth evaluating
- VM bootstrap system is the appropriate target for these configurations
- Child tasks will be implemented by separate execution (not part of this task)

## Assessment Criteria for Configurations

Each configuration should be evaluated on:

**Value Assessment:**
1. Does it solve a real problem VM users will encounter?
2. Is it terminal-only (not GUI)?
3. Would it benefit the VM development environment?
4. Is it maintainable long-term?

**Integration Complexity:**
1. Simple copy/symlink vs requires adaptation?
2. Has dependencies that need installation?
3. Needs testing infrastructure?

**Priority Rating:**
- High: Critical for productivity, low complexity
- Medium: Useful but not critical, or moderate complexity
- Low: Nice-to-have, high complexity, or niche use case

**Decision Framework:**
Only proceed with integration if all true:
1. Solves a problem VM users will actually encounter
2. Benefit worth the maintenance cost
3. Can be implemented simply
4. Will age well

## Configuration Categories to Explore

**In Scope (Terminal-Only):**
- Shell configurations (.bashrc, .zshrc, .profile, .bash_profile, .zprofile)
- Development tool configs (.gitconfig, .vimrc, .tmux.conf, .inputrc)
- System setup scripts (*.sh files)
- Package lists (terminal tools only: Brewfile, Aptfile, *packages*, *deps*)
- SSH configurations (ssh_config, sshd_config, .ssh/*)
- Terminal multiplexer configs
- Command-line utility configurations (*.conf, *.rc)

**Out of Scope (GUI Tools):**
- Desktop environment configurations
- GUI application configs
- Window manager settings
- Any graphical tool configurations

## Open Questions
- Are there specific configurations already known to be high-value (can prioritize these)?
- Should assessment prefer adapting configurations vs copying wholesale?
- What's the threshold for "too many configurations" - how many child tasks is reasonable?
