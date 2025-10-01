# `k`

dotfiles

## Quick Start

### Termux Bootstrap

1. **Configure** (one-time setup):
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/kyldvs/k/main/bootstrap/configure.sh)
```

2. **Bootstrap** your Termux environment:
```bash
curl -fsSL https://raw.githubusercontent.com/kyldvs/k/main/bootstrap/termux.sh | sh
```

3. **Authenticate** with Doppler when prompted:
```bash
~/bin/doppler login
```

4. **Re-run** bootstrap after authentication:
```bash
curl -fsSL https://raw.githubusercontent.com/kyldvs/k/main/bootstrap/termux.sh | sh
```

5. **Connect** to your VM:
```bash
ssh vm
# or
mosh vm
```
