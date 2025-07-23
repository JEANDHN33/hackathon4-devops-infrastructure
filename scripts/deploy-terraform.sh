#!/bin/bash

echo "🚀 Déploiement Infrastructure AWS - Hackathon 4 Store API"
echo "=========================================================="

# Vérifications préliminaires
echo "🔍 Vérifications..."
terraform --version || { echo "❌ Terraform requis"; exit 1; }
aws --version || { echo "❌ AWS CLI requis"; exit 1; }

# Vérification des credentials AWS
aws sts get-caller-identity || { echo "❌ Credentials AWS non configurés"; exit 1; }

echo "✅ Outils et credentials OK"

# Déploiement Terraform
cd terraform

echo -e "\n🏗️ Initialisation Terraform..."
terraform init

echo -e "\n📋 Validation de la configuration..."
terraform validate

echo -e "\n📊 Planification du déploiement..."
terraform plan -out=tfplan

echo -e "\n🚀 Déploiement de l'infrastructure (cela peut prendre 5-10 minutes)..."
terraform apply tfplan

echo -e "\n📊 Récupération des outputs..."
terraform output

echo -e "\n✅ Déploiement Terraform terminé!"

# Configuration SSH automatique
cd ..
echo -e "\n🔑 Configuration SSH..."
./scripts/configure-ssh.sh

echo -e "\n🎉 Infrastructure AWS déployée avec succès!"
echo "📋 Prochaines étapes :"
echo "1. Tester les connexions SSH"
echo "2. Configurer les services avec Ansible"
echo "3. Configurer Jenkins et Kong"
