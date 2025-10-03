# Termux Keyboard Configuration

## Description

Configure Termux keyboard shortcuts and settings for improved mobile development
experience. Termux provides a software keyboard with special keys (ESC, CTRL,
TAB, etc.) that can be customized for efficient terminal usage on mobile
devices.

## Current State

- No keyboard configuration in bootstrap scripts
- Users must manually configure keyboard settings
- bootstrap/termux.sh handles colors, font, and other UI settings
- Historical todo.md mentioned "termux keyboard shortcut settings"

## Scope

**Keyboard Configuration:**
- Extra keys row configuration (top row of special keys)
- Key combinations (CTRL-, ALT-, etc.)
- Function key bindings
- Common developer shortcuts

**Typical Extra Keys:**
- ESC, CTRL, ALT, TAB
- Arrow keys (←, ↑, →, ↓)
- Special characters (|, &, /, ~, etc.)
- Function keys (F1-F12)

**Configuration Location:**
- `~/.termux/termux.properties` (keyboard settings)
- May include extra-keys-style settings

## Success Criteria

- [ ] Keyboard shortcuts configured during bootstrap
- [ ] Configuration is idempotent
- [ ] Settings enhance mobile development workflow
- [ ] Tests validate configuration file creation
- [ ] Documentation updated in CLAUDE.md
- [ ] Follows existing termux-properties.sh pattern

## Implementation Notes

**Architecture:**
- Create `lib/steps/termux-keyboard.sh` component
- Add to `bootstrap/manifests/termux.txt`
- Call from `lib/steps/termux-main.sh`
- Follow pattern from termux-properties.sh and termux-colors.sh

**Configuration Format:**
```properties
# Example termux.properties keyboard settings
extra-keys = [['ESC','/','-','HOME','UP','END','PGUP'],['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN']]
```

**Component Structure:**
```bash
configure_termux_keyboard() {
  kd_step_start "keyboard" "Configuring keyboard shortcuts"

  # Check if already configured
  # Write configuration to ~/.termux/termux.properties
  # Use grep-based idempotency check

  kd_step_end
}
```

**Testing:**
- Add Phase to src/tests/tests/mobile-termux.test.sh
- Validate ~/.termux/termux.properties exists
- Verify extra-keys configuration present
- Test idempotency (no duplicates)

**Termux Reload:**
- May need `termux-reload-settings` after configuration
- Document manual reload requirement if necessary

## Research Needed

1. What are the most useful key combinations for mobile development?
2. What is the optimal extra-keys layout?
3. Should this be configurable via configure.sh?
4. Are there different layouts for different use cases (coding, sysadmin, etc.)?

## Dependencies

- Termux application installed
- ~/.termux directory exists
- termux-reload-settings available

## Related Files

- bootstrap/lib/steps/termux-properties.sh (similar pattern)
- bootstrap/lib/steps/termux-colors.sh (similar pattern)
- bootstrap/lib/steps/termux-font.sh (similar pattern)
- bootstrap/lib/steps/termux-main.sh (calls configuration steps)
- src/tests/tests/mobile-termux.test.sh (test coverage)

## Priority

**Low** - Quality of life improvement, not critical for functionality.

This task enhances user experience but is not blocking for core bootstrap
functionality. Should be deferred in favor of higher-priority tasks like
refactor-error-handling, vmroot-test-fixes, and vm-user-bootstrap.

## Estimated Effort

1-2 hours

## Related Principles

- **#2 Good Code is Useful**: Solves real problem (efficient mobile terminal
  usage) without overengineering
- **#5 Good Code is Unobtrusive**: Smart defaults that fade into background;
  users shouldn't need to think about keyboard config
- **#10 As Little Code as Possible**: Prefer simple defaults over complex
  configuration system

## Dependencies

None

## Alternative Approaches

1. **Minimal:** Provide documentation only, let users configure manually
2. **Configurable:** Add keyboard layout options to configure.sh
3. **Profiles:** Support multiple keyboard profiles (dev, sysadmin, etc.)
4. **Smart defaults:** Research best practices and apply sensible defaults

Following "Less but Better" principle: Start with smart defaults, add
configuration only if users actually need customization.
