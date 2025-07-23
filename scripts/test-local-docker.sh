#!/bin/bash

echo "🧪 Test local de ton Docker Compose"
echo "==================================="

# Vérification des prérequis
echo "🔍 Vérification Docker..."
docker --version || { echo "❌ Docker requis"; exit 1; }
docker compose version || { echo "❌ Docker Compose requis"; exit 1; }

# Build et démarrage
echo -e "\n🏗️ Build et démarrage des services..."
docker compose down
docker compose build --no-cache
docker compose up -d

# Attente de la disponibilité
echo -e "\n⏳ Attente de la disponibilité (60s)..."
sleep 60

# Tests de santé
echo -e "\n🏥 Tests de santé..."
echo "📊 Containers en cours :"
docker compose ps

echo -e "\n🧪 Test API Health Check :"
curl -s http://localhost:8080/actuator/health | jq '.' || echo "Health check indisponible"

echo -e "\n🧪 Test des endpoints Store :"
# Test Users
echo "Test /users :"
curl -s -w "Status: %{http_code}\n" http://localhost:8080/users -o /dev/null

# Test Contacts
echo "Test /contacts :"
curl -s -w "Status: %{http_code}\n" http://localhost:8080/contacts -o /dev/null

# Test Swagger UI
echo -e "\n🌐 Swagger UI disponible sur :"
echo "http://localhost:8080/swagger-ui/index.html"

echo -e "\n✅ Tests terminés!"
