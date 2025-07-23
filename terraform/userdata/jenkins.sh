#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "=== 🚀 Configuration Jenkins Server - Hackathon 4 ==="
dnf update -y

# Installation Java 17 (compatible avec ton Store API)
dnf install -y java-17-amazon-corretto-devel
export JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto' >> /etc/environment

# Installation Docker pour ARM64
dnf install -y docker
systemctl start docker && systemctl enable docker
usermod -a -G docker ec2-user

# Installation Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-aarch64" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Installation Maven
dnf install -y maven git

# Installation Jenkins
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
dnf install -y jenkins

# Configuration Jenkins
usermod -a -G docker jenkins
systemctl daemon-reload
systemctl enable jenkins && systemctl start jenkins

sleep 60

# Sauvegarde mot de passe initial
if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    cat /var/lib/jenkins/secrets/initialAdminPassword > /home/ec2-user/jenkins_password.txt
    chown ec2-user:ec2-user /home/ec2-user/jenkins_password.txt
fi

cat > /etc/motd << 'MOTDEOF'
🚀 JENKINS SERVER - Hackathon 4 Store API
=========================================
Java 17 | Maven | Docker | Jenkins
URL: http://localhost:8080 (via SSH tunnel)
Password: ~/jenkins_password.txt
=========================================
MOTDEOF

timedatectl set-timezone Europe/Paris
echo "✅ Jenkins Server configuré"
