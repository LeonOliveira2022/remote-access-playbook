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
│   └── (planned) init_win_ssh.ps1 # Windows SSH setup (coming soon)
└── docs/
    └── wsl_ssh_setup.md           # Detailed setup guide for WSL remote access
```

---

## ✅ Features

- 🔐 SSH key-based login from A → B (WSL)
- 🔀 Windows-to-WSL port forwarding setup
- 💻 VSCode Remote - SSH integration
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

Set up port forwarding:

```cmd
netsh interface portproxy add v4tov4 listenport=2222 listenaddress=0.0.0.0 connectport=2222 connectaddress=<WSL-IP>
netsh advfirewall firewall add rule name="WSL SSH" dir=in action=allow protocol=TCP localport=2222
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
- 🔜 A → B (Windows native via OpenSSH / WinRM)
- 🔜 Remote desktop (RDP)
- 🔜 File sharing (SMB/Samba)
- 🔜 Multi-hop tunneling & private network (Zerotier/Tailscale)

---

## 📄 License

MIT
