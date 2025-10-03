# VM User Bootstrap

## Description

Implement `bootstrap/vm.sh` for VM user-level environment setup. Currently vm.sh
is a stub that exits with a "coming soon" message. This script should provision
a non-root user's development environment on the VM.

## Current State

- vm.sh exists as a 37-line stub (bootstrap/vm.sh)
- Displays "VM Bootstrap - Coming Soon" message
- Lists planned features but does not implement them
- Related vmroot.sh (root-level setup) is complete and tested

## Scope

User-level VM environment setup including:

**Development Tools:**
- nvm (Node Version Manager)
- zsh shell with configuration
- pnpm package manager
- corepack (Node.js package manager manager)
- Claude Code CLI
- Doppler CLI
- GitHub CLI (gh)

**Environment Configuration:**
- Shell profile (.zshrc, .profile)
- Dotfiles installation/symlinking
- SSH agent configuration
- Environment variables (EDITOR, PATH, etc.)

**System Integration:**
- Integration with Termux → VM workflow
- SSH key forwarding from Termux
- Consistent tooling between Termux and VM

## Success Criteria

- [ ] vm.sh provisions complete user development environment
- [ ] Script is idempotent (can be run multiple times safely)
- [ ] All tools install and are available in PATH
- [ ] Tests validate tool installation and configuration
- [ ] Documentation updated in CLAUDE.md
- [ ] Follows existing bootstrap patterns (modular components)

## Implementation Notes

**Architecture:**
- Follow modular bootstrap pattern (lib/steps/, lib/utils/)
- Create manifest file (bootstrap/manifests/vm.txt)
- Reuse existing components where possible (colors, logging, steps)
- Build system integration via tasks/bootstrap/justfile

**Component Files Needed:**
- `lib/steps/vm-shell.sh` - zsh installation and configuration
- `lib/steps/vm-node.sh` - nvm, pnpm, corepack setup
- `lib/steps/vm-tools.sh` - Claude Code, Doppler, gh cli
- `lib/steps/vm-dotfiles.sh` - dotfiles installation
- `lib/steps/vm-profile.sh` - profile initialization
- `lib/steps/vm-main.sh` - main execution flow
- `lib/utils/header-vm.sh` - script header

**Dependencies:**
- Assumes user exists (created by vmroot.sh)
- Requires network access for tool downloads
- May need sudo for some system-level configurations

**Testing:**
- Create src/tests/tests/vm.test.sh
- Create Docker compose setup (docker-compose.vm.yml)
- Add to `just test all` suite
- Validate idempotency

**User Experience:**
```bash
# Run as VM user (not root)
curl -fsSL https://raw.githubusercontent.com/kyldvs/k/main/bootstrap/vm.sh | sh
```

## Dependencies

- vmroot.sh must be run first (creates user, sets up sudo/SSH)
- User must have sudo access
- Network connectivity required

## Related Files

- bootstrap/vm.sh (current stub)
- bootstrap/vmroot.sh (root-level setup, complete)
- bootstrap/termux.sh (mobile environment, complete)
- docs/plan/vm-root-bootstrap/ (related root setup docs)

## Priority

**Low** - Large feature that completes the VM setup stack, but not urgent.
Higher priority tasks (error handling, test fixes, CI) should be completed
first.

## Estimated Effort

8-10 hours

## Related Principles

- **#2 Good Code is Useful**: Completes the development environment stack,
  solving real user needs
- **#10 As Little Code as Possible**: Complete the stack with minimal
  additional complexity; reuse existing patterns
- **#9 Good Code is Sustainable**: Consistent tooling and environment reduces
  cognitive load
- **#5 Good Code is Unobtrusive**: Setup should be invisible once complete;
  tools just work

## References

Historical todo.md items covered by this task:
- vm user nvm, zsh, pnpm, corepack, claude code, doppler, gh cli
- Dotfiles installation
- Development environment configuration
