# WSL SSH Setup Guide (A → B's WSL)

## 📄 Overview

This guide helps you configure **secure SSH key-based access** from computer **A** to **B's WSL (Ubuntu)** environment via custom port forwarding and firewall configuration.

---

## 🔎 Environment

| Role | Host OS  | Username |
|------|----------|----------|
| A    | Windows  | `Leon`   |
| B    | Windows + WSL2 | Windows: `Steven` / WSL: `steven` |

Port: `2222` (custom for WSL)

---

## ✅ Step 1: Generate SSH Key on A

Run this in **A's CMD** or **PowerShell**:

```sh
ssh-keygen -t ed25519 -f %USERPROFILE%\.ssh\b_wsl_ed25519
```

This will generate:
- Private key: `%USERPROFILE%\.ssh\b_wsl_ed25519`
- Public key: `%USERPROFILE%\.ssh\b_wsl_ed25519.pub`

---

## 🌐 Step 2: Configure SSH in B's WSL

### 2.1 Run the auto setup script

Copy your public key into `scripts/init_wsl_ssh.sh` under the variable `PUBLIC_KEY=...`

Then run inside WSL:

```bash
bash scripts/init_wsl_ssh.sh
```

Or do it manually:

```bash
sudo apt update && sudo apt install -y openssh-server

sudo sed -i 's/^#\?Port .*/Port 2222/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?ListenAddress .*/ListenAddress 0.0.0.0/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?PubkeyAuthentication .*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config

mkdir -p ~/.ssh
chmod 700 ~/.ssh
cat <<EOF > ~/.ssh/authorized_keys
<PASTE YOUR PUBLIC KEY HERE>
EOF
chmod 600 ~/.ssh/authorized_keys

sudo service ssh restart
```

---

## 🚧 Step 3: Forward Port in B's Windows

### 3.1 Get WSL IP

In WSL:
```bash
ip -4 addr show eth0 | grep inet
```

### 3.2 Forward Windows:2222 → WSL:2222

Run in **B's Windows CMD** as admin:

```cmd
netsh interface portproxy add v4tov4 listenport=2222 listenaddress=0.0.0.0 connectport=2222 connectaddress=<WSL-IP>
```

### 3.3 Open Firewall Port

```cmd
netsh advfirewall firewall add rule name="WSL SSH" dir=in action=allow protocol=TCP localport=2222
```

---

## 🔍 Step 4: A connects to B's WSL

### Option 1: Direct
```bash
ssh -i ~/.ssh/b_wsl_ed25519 steven@<B_IP> -p 2222
```

### Option 2: Use SSH Config

Create `~/.ssh/config`:

```ssh
Host b-wsl
    HostName <B_IP>
    Port 2222
    User steven
    IdentityFile ~/.ssh/b_wsl_ed25519
    IdentitiesOnly yes
```

Then connect:
```bash
ssh b-wsl
```

---

## 📂 Step 5: VSCode Remote SSH into WSL

Install **Remote - SSH** extension in VSCode.

Launch via:
```bash
code --folder-uri "vscode-remote://ssh-remote+b-wsl/home/steven"
```

Or via Command Palette: `Remote-SSH: Connect to Host...` and select `b-wsl`.

---

# Windows SSH Setup Guide (A → B's Windows)

## 📄 Overview

This guide enables **SSH access directly into Windows (B)** from computer **A**, ideal for native remote management and VSCode integration.

---

## 🔎 Environment

| Role | OS       | Username |
|------|----------|----------|
| A    | Windows  | `Leon`   |
| B    | Windows  | `Steven` |

Port: `22222` (custom)

---

## ✅ Step 1: Generate SSH Key on A

```cmd
ssh-keygen -t ed25519 -f %USERPROFILE%\.ssh\b_win_ed25519
```

---

## ⚖️ Step 2: Run Setup Script on B

Run the PowerShell script as **administrator**:

```powershell
scripts/init_win_ssh.ps1
```

This will:
- Install OpenSSH.Server
- Enable and start the `sshd` service
- Configure port `22222`
- Add firewall rule
- Create `.ssh/authorized_keys`

> You still need to **paste your public key** into `authorized_keys` manually or via script.

---

## 🔧 Step 3: Paste Public Key to B

On A:
```cmd
type %USERPROFILE%\.ssh\b_win_ed25519.pub
```

On B:
```powershell
notepad $env:USERPROFILE\.ssh\authorized_keys
```

Paste and save. Then restart sshd:
```powershell
Restart-Service sshd
```

---

## 🔍 Step 4: A connects to B

### Option 1: Direct
```bash
ssh -i ~/.ssh/b_win_ed25519 steven@<B_IP> -p 22222
```

### Option 2: Use SSH Config

```ssh
Host b-win
    HostName <B_IP>
    Port 22222
    User steven
    IdentityFile ~/.ssh/b_win_ed25519
    IdentitiesOnly yes
```

Then connect:
```bash
ssh b-win
```

---

## 📂 Step 5: VSCode Remote SSH into Windows

```bash
code --folder-uri "vscode-remote://ssh-remote+b-win/C:/Users/Steven"
```

Or use Command Palette and select `b-win`.

---

## 🎉 Done!

You're now ready to manage B's WSL and Windows environments securely over SSH from A, with full VSCode integration.
