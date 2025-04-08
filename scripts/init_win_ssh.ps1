# init_win_ssh.ps1
# One-click setup script for enabling SSH access to Windows on machine B

<#+
.DESCRIPTION
This script enables the OpenSSH server on Windows, sets a custom port,
adds necessary firewall rules, and prepares the system for SSH access.
It is intended to be run **as administrator**.

.Author: Your Name
.Date: 2025-04-08
#>

$port = 22222
$username = $env:USERNAME
$sshd_config_path = "$env:ProgramData\ssh\sshd_config"

# 1. Enable OpenSSH Server
Write-Host "[*] Installing OpenSSH Server..."
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# 2. Start and enable sshd
Write-Host "[*] Starting and enabling sshd service..."
Start-Service sshd
Set-Service -Name sshd -StartupType Automatic

# 3. Allow port through firewall
Write-Host "[*] Adding firewall rule for port $port..."
New-NetFirewallRule -Name "sshd-$port" -DisplayName "OpenSSH Server on $port" -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort $port

# 4. Modify sshd_config for custom port and pubkey auth
Write-Host "[*] Configuring sshd_config..."
if (!(Test-Path $sshd_config_path)) {
    Write-Error "sshd_config not found at $sshd_config_path"
    exit 1
}

$content = Get-Content $sshd_config_path
$content = $content -replace "^#?Port\s+\d+", "Port $port"
$content = $content -replace "^#?PubkeyAuthentication\s+\w+", "PubkeyAuthentication yes"
$content = $content -replace "^#?AuthorizedKeysFile\s+.*", "AuthorizedKeysFile .ssh/authorized_keys"
Set-Content -Path $sshd_config_path -Value $content

# 5. Create .ssh folder and authorized_keys if not exist
Write-Host "[*] Preparing .ssh folder for user $username..."
$ssh_path = "$env:USERPROFILE\.ssh"
$auth_file = "$ssh_path\authorized_keys"
New-Item -ItemType Directory -Path $ssh_path -Force | Out-Null
if (!(Test-Path $auth_file)) {
    New-Item -ItemType File -Path $auth_file -Force | Out-Null
}

# Set permissions
icacls $ssh_path /inheritance:r | Out-Null
icacls $ssh_path /grant "$username:(OI)(CI)F" | Out-Null
icacls $auth_file /inheritance:r | Out-Null
icacls $auth_file /grant "$username:R" | Out-Null

# 6. Restart sshd
Write-Host "[*] Restarting sshd..."
Restart-Service sshd

Write-Host "[+] SSH server setup complete on port $port." -ForegroundColor Green
Write-Host "You can now connect from A using:"
Write-Host "ssh $username@<B_Public_IP> -p $port"
