#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "=== 📱 Configuration API Server - Hackathon 4 Store ==="
dnf update -y

# Installation Java 17 (compatible avec ton Store API)
dnf install -y java-17-amazon-corretto-devel
export JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto

# Installation Docker pour ARM64
dnf install -y docker
systemctl start docker && systemctl enable docker
usermod -a -G docker ec2-user

# Installation Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-aarch64" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Outils
dnf install -y git curl jq htop tree

# Répertoire de déploiement
mkdir -p /opt/api-deployment
chown ec2-user:ec2-user /opt/api-deployment

# Configuration Docker Compose pour Store API
cat > /opt/api-deployment/docker-compose.yml << 'COMPOSEEOF'
services:
  db:
    image: postgres:15-alpine
    container_name: hackathon4-postgres
    environment:
      POSTGRES_DB: hackathon4_db
      POSTGRES_USER: api_user
      POSTGRES_PASSWORD: secure_password_123
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U api_user -d hackathon4_db"]
      interval: 30s
      timeout: 10s
      retries: 3
    networks:
      - app-network

  store:
    image: hackathon4-store-api:latest
    container_name: hackathon4-store-app
    depends_on:
      db:
        condition: service_healthy
    environment:
      SPRING_DATASOURCE_URL: jdbc:postgresql://db:5432/hackathon4_db
      SPRING_DATASOURCE_USERNAME: api_user
      SPRING_DATASOURCE_PASSWORD: secure_password_123
      SERVER_PORT: 8080
    ports:
      - "8080:8080"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    networks:
      - app-network

volumes:
  postgres_data:

networks:
  app-network:
COMPOSEEOF

chown ec2-user:ec2-user /opt/api-deployment/docker-compose.yml

cat > /etc/motd << 'MOTDEOF'
📱 API SERVER - Hackathon 4 Store
=================================
Java 17 | Docker | PostgreSQL
Store API Port: 8080
Deployment: /opt/api-deployment
=================================
MOTDEOF

timedatectl set-timezone Europe/Paris
echo "✅ API Server configuré"
