# VM Mosh Server Setup

## Description

Ensure mosh-server is installed and properly configured on the VM for roaming
SSH connections. Mosh (mobile shell) provides better connectivity for mobile
development by maintaining connections across IP changes and network
interruptions.

## Current State

- Termux installs mosh client (bootstrap/lib/steps/packages.sh)
- next-steps.sh mentions mosh connection: "mosh vm"
- Historical todo.md mentioned "vm mosh server"
- Unclear if mosh-server is installed on VM
- No explicit mosh server setup in vmroot.sh or vm.sh (stub)

## Research Needed

**Verify Current Behavior:**
1. Does the VM already have mosh-server installed?
2. Is it part of base VM image or installed separately?
3. Are there firewall/port requirements?
4. Does mosh work out-of-box with current setup?

**If Not Working:**
- Where should mosh-server be installed? (vmroot.sh vs vm.sh)
- What ports need to be opened? (UDP 60000-61000 typical)
- Does it require additional configuration?

## Scope

**Mosh Server Installation:**
- Install mosh package on VM
- Verify mosh-server binary available
- Ensure proper permissions

**Network Configuration:**
- Open required UDP ports (if firewall active)
- Document port range requirements
- Test connectivity from Termux client

**Integration:**
- Add to appropriate bootstrap script (vmroot.sh or vm.sh)
- Follow modular component pattern
- Add idempotency checks

## Success Criteria

- [ ] Mosh-server installed on VM
- [ ] Client from Termux can connect via mosh
- [ ] Connection persists through IP changes
- [ ] Tests validate mosh connectivity (if feasible)
- [ ] Documentation updated
- [ ] Port requirements documented

## Implementation Notes

**Decision Point: vmroot.sh vs vm.sh**

Option A: Add to vmroot.sh (root-level)
- Installs system package
- Available for all users
- Managed by root

Option B: Add to vm.sh (user-level)
- User installs via sudo
- More granular control
- Part of user environment setup

**Recommendation:** vmroot.sh (system-level package, benefits all users)

**Component Structure:**
```bash
# lib/steps/vmroot-mosh.sh
install_mosh_server() {
  kd_step_start "mosh" "Installing mosh-server"

  if command -v mosh-server >/dev/null 2>&1; then
    kd_step_skip "mosh-server already installed"
    return 0
  fi

  # Detect package manager and install
  if command -v apt-get >/dev/null 2>&1; then
    apt-get update && apt-get install -y mosh
  elif command -v yum >/dev/null 2>&1; then
    yum install -y mosh
  else
    kd_error "Unknown package manager"
    return 1
  fi

  kd_step_end
}
```

**Testing:**
- Add phase to vmroot.test.sh
- Verify mosh-server command exists
- Test mosh connection (may need network simulation)
- Or document as manual verification step

## Dependencies

- Root access on VM (for package installation)
- Network connectivity
- Compatible with VM OS/distribution

## Related Files

- bootstrap/vmroot.sh (likely home for this feature)
- bootstrap/lib/steps/packages.sh (termux mosh client)
- bootstrap/lib/steps/next-steps.sh (mentions mosh vm)
- src/tests/tests/vmroot.test.sh (test coverage)

## Priority

**Low-Medium** - Nice to have, but basic SSH works. May already be functional.

## Investigation First

Before implementing:
1. Test if mosh already works
2. Check if VM image includes mosh-server
3. Document current behavior
4. Only implement if actually needed

Following "Less but Better": Don't add complexity if it already works or isn't
needed. Verify the problem exists before solving it.
