#!/bin/bash

echo "🔑 Configuration SSH automatique"
echo "==============================="

cd terraform

# Récupération des IPs depuis Terraform
BASTION_IP=$(terraform output -raw bastion_public_ip)
JENKINS_IP=$(terraform output -raw jenkins_private_ip)
API_SERVER_IP=$(terraform output -raw api_server_private_ip)
KONG_IP=$(terraform output -raw kong_private_ip)

echo "📋 IPs récupérées :"
echo "  Bastion: $BASTION_IP"
echo "  Jenkins: $JENKINS_IP"
echo "  API Server: $API_SERVER_IP"
echo "  Kong: $KONG_IP"

# Configuration SSH
cat > ~/.ssh/config << SSHEOF
# Configuration SSH - Hackathon 4 Store API

Host bastion
    HostName $BASTION_IP
    User ec2-user
    Port 4222
    IdentityFile ~/.ssh/hackathon4_rsa
    StrictHostKeyChecking no

Host jenkins
    HostName $JENKINS_IP
    User ec2-user
    Port 22
    IdentityFile ~/.ssh/hackathon4_rsa
    ProxyJump bastion
    StrictHostKeyChecking no

Host api-server
    HostName $API_SERVER_IP
    User ec2-user
    Port 22
    IdentityFile ~/.ssh/hackathon4_rsa
    ProxyJump bastion
    StrictHostKeyChecking no

Host kong-server
    HostName $KONG_IP
    User ec2-user
    Port 22
    IdentityFile ~/.ssh/hackathon4_rsa
    ProxyJump bastion
    StrictHostKeyChecking no
SSHEOF

echo "✅ Configuration SSH créée"

# Test des connexions
echo -e "\n🧪 Test des connexions SSH..."
ssh -o ConnectTimeout=30 bastion "echo '✅ Bastion accessible'" || echo "❌ Bastion non accessible"

cd ..
echo "🎉 Configuration SSH terminée!"
