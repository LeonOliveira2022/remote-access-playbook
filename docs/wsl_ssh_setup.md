# ✅ A 电脑通过 SSH 密钥登录 B 电脑的 WSL 子系统 —— 配置全流程

## 🖥️ 环境说明

- A 电脑（客户端）：Windows，用户为 `Leon`
- B 电脑（服务器）：Windows + WSL，WSL 用户为 `steven`
- 目标：从 A 电脑使用 SSH 密钥连接 B 的 WSL 子系统（端口 2222），并在 VSCode 中远程编辑文件

---

## 🪪 第 1 步：A 电脑生成 SSH 密钥

在 A 电脑 CMD 中运行：

```cmd
ssh-keygen -t ed25519 -f %USERPROFILE%\.ssh\b_wsl_ed25519
```

按提示操作，生成两个文件：

- 私钥：`C:\Users\Leon\.ssh\b_wsl_ed25519`
- 公钥：`C:\Users\Leon\.ssh\b_wsl_ed25519.pub`

---

## 🌐 第 2 步：配置 B 电脑的 WSL

### 2.1 安装并启动 SSH 服务（在 WSL 中执行）

```bash
sudo apt update
sudo apt install openssh-server
sudo service ssh start
```

### 2.2 修改 sshd_config 文件

```bash
sudo nano /etc/ssh/sshd_config
```

确保配置如下：

```
Port 2222
ListenAddress 0.0.0.0
PasswordAuthentication no
PubkeyAuthentication yes
PermitRootLogin prohibit-password
AuthorizedKeysFile .ssh/authorized_keys
```

重启 SSH：

```bash
sudo service ssh restart
```

### 2.3 添加 A 端公钥到 `~/.ssh/authorized_keys`

1. 在 A 电脑查看公钥内容：

```cmd
type %USERPROFILE%\.ssh\b_wsl_ed25519.pub
```

2. 在 B 的 WSL 中：

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
nano ~/.ssh/authorized_keys
```

粘贴 A 端公钥（必须是一整行），保存后：

```bash
chmod 600 ~/.ssh/authorized_keys
```

---

## 🔁 第 3 步：配置端口转发（在 B 的 Windows CMD 中）

### 3.1 获取 WSL IP

```bash
ip -4 addr show eth0 | grep inet
```

假设 WSL IP 为 `172.28.19.45`

### 3.2 设置端口转发

```cmd
netsh interface portproxy add v4tov4 listenport=2222 listenaddress=0.0.0.0 connectport=2222 connectaddress=172.28.19.45
```

### 3.3 开放防火墙端口

```cmd
netsh advfirewall firewall add rule name="WSL SSH" dir=in action=allow protocol=TCP localport=2222
```

---

## 🧪 第 4 步：A 电脑测试连接

```bash
ssh -i ~/.ssh/b_wsl_ed25519 steven@58.177.71.154 -p 2222
```

---

## 🧾 第 5 步：A 端配置 `.ssh/config`

文件：`C:\Users\Leon\.ssh\config`

```ssh
Host b-wsl
    HostName 58.177.71.154
    Port 2222
    User steven
    IdentityFile ~/.ssh/b_wsl_ed25519
    IdentitiesOnly yes
```

测试连接：

```bash
ssh b-wsl
```

---

## 💻 第 6 步：使用 VSCode 编辑远程 WSL 文件

### 安装插件
- VSCode 安装插件：**Remote - SSH**

### 打开方式
打开 PowerShell 或 CMD，执行：

```bash
code --folder-uri "vscode-remote://ssh-remote+b-wsl/home/steven"
```

即可远程打开 WSL 中 `/home/steven` 文件夹。

---
```

---

## 📦 `.bat` 脚本：A 电脑一键连接（`connect_b_wsl.bat`）

```bat
@echo off
set "SSH_CONFIG=%USERPROFILE%\.ssh\config"
if not exist "%SSH_CONFIG%" (
    echo SSH config 文件不存在，请先配置 %SSH_CONFIG%
    pause
    exit /b
)

echo 正在连接 B 电脑 WSL...
ssh b-wsl
```

---

## 📜 WSL 初始化脚本：B 端设置 SSH 服务 + 公钥（`init_wsl_ssh.sh`）

这个脚本适合你从 WSL 中运行，**你只需要提前把公钥内容粘贴到 `PUBLIC_KEY` 变量中即可**：

```bash
#!/bin/bash

# 设置你从 A 电脑复制来的公钥（必须是完整一行）
PUBLIC_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAZ...你的key... leon@DESKTOP-xxx"

# 安装 openssh-server
sudo apt update && sudo apt install -y openssh-server

# 修改 sshd 配置
sudo sed -i 's/^#\?Port .*/Port 2222/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?ListenAddress .*/ListenAddress 0.0.0.0/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?PubkeyAuthentication .*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config

# 设置 .ssh 目录与公钥
mkdir -p ~/.ssh
echo "$PUBLIC_KEY" > ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

# 启动 ssh 服务
sudo service ssh restart

echo "✅ SSH 服务配置完成，请确认 Windows 已设置端口转发。"
```
