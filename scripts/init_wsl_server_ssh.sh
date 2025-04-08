#!/bin/bash

# 设置你从 A 电脑复制来的公钥（必须是完整一行）
PUBLIC_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAZ...your_key_here... leon@DESKTOP-xxx"

echo "🔧 正在初始化 WSL 中的 SSH 环境..."

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

echo "✅ SSH 服务配置完成！请确认 Windows 层已设置端口转发。"
echo "LogLevel DEBUG3" | sudo tee -a /etc/ssh/sshd_config
