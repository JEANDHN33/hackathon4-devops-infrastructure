#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "=== 🌐 Configuration Kong Gateway - Hackathon 4 ==="
dnf update -y

# Installation Docker pour ARM64
dnf install -y docker
systemctl start docker && systemctl enable docker
usermod -a -G docker ec2-user

# Installation Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-aarch64" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Outils
dnf install -y git curl jq htop tree

# Répertoire Kong
mkdir -p /opt/kong
chown ec2-user:ec2-user /opt/kong

# Configuration Kong
cat > /opt/kong/docker-compose.yml << 'KONGEOF'
services:
  kong-database:
    image: postgres:13-alpine
    restart: always
    environment:
      POSTGRES_USER: kong
      POSTGRES_PASSWORD: kong123
      POSTGRES_DB: kong
    volumes:
      - kong-datastore:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "kong"]
      interval: 5s
      timeout: 5s
      retries: 5

  kong-migrations:
    image: kong/kong-gateway:3.4.2-alpine
    command: kong migrations bootstrap
    environment:
      KONG_DATABASE: postgres
      KONG_PG_HOST: kong-database
      KONG_PG_USER: kong
      KONG_PG_PASSWORD: kong123
      KONG_PG_DATABASE: kong
    depends_on:
      kong-database:
        condition: service_healthy
    restart: "no"

  kong:
    image: kong/kong-gateway:3.4.2-alpine
    restart: always
    environment:
      KONG_DATABASE: postgres
      KONG_PG_HOST: kong-database
      KONG_PG_USER: kong
      KONG_PG_PASSWORD: kong123
      KONG_PG_DATABASE: kong
      KONG_ADMIN_LISTEN: 0.0.0.0:8001
      KONG_PROXY_LISTEN: 0.0.0.0:8000
    depends_on:
      kong-migrations:
        condition: service_completed_successfully
    ports:
      - "8000:8000"  # Proxy public (comme dans ton schéma)
      - "8001:8001"  # Admin API
    healthcheck:
      test: ["CMD", "kong", "health"]
      interval: 30s
      timeout: 10s
      retries: 3

volumes:
  kong-datastore:
KONGEOF

chown ec2-user:ec2-user /opt/kong/docker-compose.yml

# Démarrage automatique Kong
su - ec2-user -c "cd /opt/kong && docker-compose up -d" &

cat > /etc/motd << 'MOTDEOF'
🌐 KONG GATEWAY - Hackathon 4 Store API
======================================
Proxy: Port 8000 (Public)
Admin: Port 8001 (Internal)
Ready for Store API routing
======================================
MOTDEOF

timedatectl set-timezone Europe/Paris
echo "✅ Kong Gateway configuré"
