# init_win_ssh.ps1
# 在 B 电脑（Windows）上运行，配置 OpenSSH Server + 公钥登录

<#
.SYNOPSIS
一键配置 Windows 上的 OpenSSH Server 环境（用于 A 远程连接）
#>

# === 配置项 ===
$port = 22222
$username = $env:USERNAME
$sshd_config = "$env:ProgramData\ssh\sshd_config"
$ssh_folder = "$env:USERPROFILE\.ssh"
$authorized_keys = "$ssh_folder\authorized_keys"

# === 安装 OpenSSH Server ===
Write-Host "`n[*] 检查并安装 OpenSSH Server..."
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 -ErrorAction SilentlyContinue

# === 启动服务并设置开机自启 ===
Write-Host "[*] 启动 sshd 服务并设置为自动启动..."
Start-Service sshd
Set-Service sshd -StartupType Automatic

# === 防火墙设置 ===
Write-Host "[*] 设置防火墙规则（端口 $port）..."
if (-not (Get-NetFirewallRule -Name "sshd-$port" -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -Name "sshd-$port" -DisplayName "OpenSSH Server on $port" `
        -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort $port
}

# === 修改 sshd_config ===
Write-Host "[*] 修改 sshd_config 配置..."
if (!(Test-Path $sshd_config)) {
    Write-Error "未找到 $sshd_config，请检查 OpenSSH 安装状态。"
    exit 1
}

(Get-Content $sshd_config) |
    ForEach-Object {
        $_ -replace '^#?Port\s+\d+', "Port $port" `
           -replace '^#?PubkeyAuthentication\s+\w+', 'PubkeyAuthentication yes' `
           -replace '^#?PasswordAuthentication\s+\w+', 'PasswordAuthentication no' `
           -replace '^#?AuthorizedKeysFile\s+.*', 'AuthorizedKeysFile .ssh/authorized_keys'
    } | Set-Content $sshd_config

# === 创建 .ssh 目录和密钥文件 ===
Write-Host "[*] 准备 .ssh 目录和 authorized_keys 文件..."
New-Item -ItemType Directory -Path $ssh_folder -Force | Out-Null
if (!(Test-Path $authorized_keys)) {
    New-Item -ItemType File -Path $authorized_keys -Force | Out-Null
}

# === 设置权限 ===
Write-Host "[*] 设置文件权限..."
icacls $ssh_folder /inheritance:r | Out-Null
icacls $ssh_folder /grant "${username}:(OI)(CI)F" | Out-Null
icacls $authorized_keys /inheritance:r | Out-Null
icacls $authorized_keys /grant "${username}:R" | Out-Null

# === 重启 sshd 服务 ===
Write-Host "[*] 重启 sshd 服务以应用配置..."
Restart-Service sshd

# === 结束 ===
Write-Host "`n✅ OpenSSH Server 配置完成！" -ForegroundColor Green
Write-Host "📌 请将 A 电脑的公钥粘贴到以下路径："
Write-Host "   $authorized_keys" -ForegroundColor Yellow
Write-Host "🔗 你可以用以下命令从 A 电脑连接："
Write-Host "   ssh $username@<B公网IP> -p $port`n"
