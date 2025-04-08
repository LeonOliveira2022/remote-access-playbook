# 🧰 Remote Access Playbook

A practical playbook for setting up secure remote access from one PC (A) to another (B), covering both **WSL** and **Windows** environments.

---

## 📂 Structure

```
remote-access-playbook/
├── README.md
├── scripts/
│   ├── connect_b_wsl.bat          # Connect to B's WSL from A
│   ├── init_wsl_ssh.sh            # One-click setup script for B's WSL
│   └── init_win_ssh.ps1           # One-click setup for B's Windows (Run as Administrator)
└── docs/
    └── wsl_ssh_setup.md           # Detailed setup guide for WSL remote access
```

---

## ✅ Features

- 🔐 SSH key-based login from A → B (WSL & Windows)
- 🔀 Windows-to-WSL port forwarding setup
- 💻 VSCode Remote - SSH integration
- 🧰 One-click setup scripts for both Windows and WSL
- 📦 Extensible for other protocols (WinRM, RDP, SMB...)

---

## 🚀 Quick Start

### 1. On B's WSL:

Run the setup script:

```bash
bash scripts/init_wsl_ssh.sh
```

(Replace `PUBLIC_KEY=` inside the script with your actual SSH public key.)

### 2. On B's Windows:

Run the PowerShell setup (as administrator):

```powershell
powershell -ExecutionPolicy Bypass -File scripts/init_win_ssh.ps1
```

### 3. On A:

Connect via:

```bash
ssh -i ~/.ssh/b_wsl_ed25519 steven@<B_IP> -p 2222
```

Or, after editing your `~/.ssh/config`:

```bash
ssh b-wsl
```

### 4. (Optional) Use VSCode to edit files remotely:

```bash
code --folder-uri "vscode-remote://ssh-remote+b-wsl/home/steven"
```

---

## 📖 Full Guide

See [`docs/wsl_ssh_setup.md`](docs/wsl_ssh_setup.md) for detailed step-by-step instructions.

---

## 🛣️ Roadmap

- ✅ A → B (WSL via SSH)
- ✅ A → B (Windows native via OpenSSH)
- 🔜 Remote desktop (RDP)
- 🔜 File sharing (SMB/Samba)
- 🔜 Multi-hop tunneling & private network (Zerotier/Tailscale)

---

## 📄 License

MIT
