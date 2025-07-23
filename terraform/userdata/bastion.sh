#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "=== 🛡️ Configuration Bastion Host - Hackathon 4 ==="
dnf update -y

# Configuration SSH sur port 4222 (comme dans ton schéma)
sed -i 's/#Port 22/Port 4222/' /etc/ssh/sshd_config
sed -i 's/^Port 22/Port 4222/' /etc/ssh/sshd_config

# Sécurisation SSH
cat >> /etc/ssh/sshd_config << 'SSHEOF'
PermitRootLogin no
PasswordAuthentication no
X11Forwarding no
MaxAuthTries 3
ClientAliveInterval 300
SSHEOF

systemctl restart sshd

# Installation fail2ban pour sécurité
dnf install -y epel-release fail2ban
cat > /etc/fail2ban/jail.local << 'F2BEOF'
[sshd]
enabled = true
port = 4222
logpath = /var/log/secure
maxretry = 3
bantime = 1800
F2BEOF

systemctl enable fail2ban && systemctl start fail2ban

# Outils de monitoring
dnf install -y htop ncdu tree curl vim git

# Message de bienvenue
cat > /etc/motd << 'MOTDEOF'
🛡️ BASTION HOST - Hackathon 4 Store API
=======================================
Port SSH: 4222 | Fail2ban: Actif
ProxyJump configuré pour Jenkins/API/Kong
=======================================
MOTDEOF

timedatectl set-timezone Europe/Paris
echo "✅ Bastion Host configuré"
