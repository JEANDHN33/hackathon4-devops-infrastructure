# 🚀 Hackathon 4 DevOps - Store API avec Architecture Terraform + Ansible

## 📊 Architecture

Infrastructure DevOps complète déployant une Store API Spring Boot sur AWS avec pipeline CI/CD automatisé.

🌐 Internet
↓
🛡️ Bastion Host (15.236.123.110:4222)
↓ SSH ProxyJump
┌─────────────────────────────────────────┐
│ �� Jenkins (10.0.1.77:8080) │
│ 📱 API Server (10.0.1.212:8080) │
│ 🌐 Kong Gateway (10.0.1.202:8000) │
└─────────────────────────────────────────┘
↓ Kong Gateway
🌐 API Publique (15.236.133.177:8000/api)

text

## 🛠️ Technologies Utilisées

- **Infrastructure**: Terraform (AWS EC2, VPC, Security Groups)
- **Configuration**: Ansible (Playbooks + Rôles)
- **CI/CD**: Jenkins avec pipeline automatisé
- **Application**: Spring Boot + PostgreSQL
- **API Gateway**: Kong Gateway
- **Containerisation**: Docker + Docker Compose

## 🚀 Déploiement

### 1. Infrastructure (Terraform)

cd terraform
terraform init
terraform plan
terraform apply

text

### 2. Configuration Services (Ansible)

cd ansible
./deploy.sh

text

### 3. Accès Services

- **Jenkins**: `ssh -L 8081:localhost:8080 jenkins` → http://localhost:8081
- **API Store**: http://15.236.133.177:8000/api
- **Swagger UI**: http://15.236.133.177:8000/api/swagger-ui/index.html

## 📋 Endpoints API

- `GET /api/users` - Liste des utilisateurs
- `POST /api/users` - Créer un utilisateur  
- `GET /api/contacts` - Liste des contacts
- `POST /api/contacts` - Créer un contact
- `GET /api/actuator/health` - Health check

## 🔧 Structure du Projet

hackathon4-devops-infrastructure/
├── terraform/ # Infrastructure as Code
├── ansible/ # Configuration Management
├── src/ # Code Store API Spring Boot
├── scripts/ # Scripts d'automatisation
└── docs/ # Documentation

text

## 🎯 Architecture DevOps

1. **Terraform** déploie l'infrastructure AWS
2. **Ansible** configure les services (Jenkins, Kong, Docker)
3. **Jenkins** automatise le déploiement de l'API
4. **Kong Gateway** expose l'API publiquement

## 🏆 Réalisations Techniques

- ✅ Infrastructure cloud sécurisée (Bastion + ProxyJump)
- ✅ Pipeline CI/CD automatisé
- ✅ API Gateway pour exposition publique
- ✅ Configuration Management avec Ansible
- ✅ Monitoring et health checks
