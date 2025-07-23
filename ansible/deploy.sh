#!/bin/bash

echo "🚀 Déploiement Hackathon 4 DevOps avec Ansible"
echo "=============================================="

# Test de connectivité
echo "🔍 Test de connectivité vers les instances..."
ansible all -m ping

# Déploiement complet
echo "⚙️ Configuration des services via Ansible..."
ansible-playbook site.yml

echo "✅ Déploiement terminé !"
echo "🌐 Votre Store API est accessible sur: http://15.236.133.177:8000/api"
