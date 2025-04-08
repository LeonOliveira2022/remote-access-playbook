@echo off
set "SSH_CONFIG=%USERPROFILE%\.ssh\config"
if not exist "%SSH_CONFIG%" (
    echo SSH config 文件不存在，请先配置 %SSH_CONFIG%
    pause
    exit /b
)

echo 正在连接 B 电脑 WSL...
ssh b-ws
