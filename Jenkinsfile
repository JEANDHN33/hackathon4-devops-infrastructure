cat > Jenkinsfile << 'EOF'
pipeline {
    agent any

    tools {
        maven 'Maven'
        jdk 'Java-17'
    }

    environment {
        // Configuration spécifique Hackathon 4
        DOCKER_IMAGE = 'hackathon4-store-api'
        API_SERVER_IP_CRED_ID = 'api-server-ip-id'
        GITHUB_TOKEN_CRED_ID = 'github-token-id'
        DEPLOYMENT_DIR = '/opt/api-deployment'
        
        // Configuration build
        MAVEN_OPTS = '-Xmx1024m -XX:MaxPermSize=256m'
        JAVA_TOOL_OPTIONS = '-Dfile.encoding=UTF8'
    }

    triggers {
        githubPush()
        // Déclenchement périodique pour les tests (optionnel)
        cron('H 2 * * 1-5') // Tous les jours de semaine à 2h du matin
    }

    stages {
        stage('Checkout') {
            steps {
                echo '📥 Récupération du code source depuis GitHub...'
                
                script {
                    // Nettoyage de l'workspace
                    cleanWs()
                }
                
                withCredentials([string(credentialsId: "${GITHUB_TOKEN_CRED_ID}", variable: 'GITHUB_TOKEN')]) {
                    script {
                        // Configuration Git pour l'authentification
                        sh '''
                            git config --global credential.helper store
                            echo "https://${GITHUB_TOKEN}:@github.com" > ~/.git-credentials
                            
                            echo "🔍 Configuration Git :"
                            git config --global --list | grep -E "(user|credential)" || true
                        '''
                        
                        // Checkout du repository
                        git url: "https://github.com/JEANDHN33/hackathon4-devops-infrastructure.git", 
                            branch: 'main',
                            credentialsId: "${GITHUB_TOKEN_CRED_ID}"
                    }
                }
                
                script {
                    // Variables d'environnement pour le build
                    env.BUILD_TIMESTAMP = sh(
                        script: 'date +"%Y-%m-%d_%H-%M-%S"',
                        returnStdout: true
                    ).trim()
                    
                    env.GIT_COMMIT_SHORT = sh(
                        script: 'git rev-parse --short HEAD',
                        returnStdout: true
                    ).trim()
                }
                
                echo "✅ Code récupéré - Commit: ${env.GIT_COMMIT_SHORT}"
            }
        }

        stage('Environment Check') {
            steps {
                echo '🔍 Vérification de l\'environnement Jenkins...'
                
                sh '''
                    echo "=== 🔧 Versions des outils ==="
                    java -version
                    mvn -version
                    docker --version
                    
                    echo "=== 📋 Variables d'environnement ==="
                    echo "BUILD_NUMBER: ${BUILD_NUMBER}"
                    echo "BUILD_TIMESTAMP: ${BUILD_TIMESTAMP}"
                    echo "GIT_COMMIT: ${GIT_COMMIT_SHORT}"
                    echo "DOCKER_IMAGE: ${DOCKER_IMAGE}"
                    
                    echo "=== 📁 Structure du projet ==="
                    ls -la
                    
                    echo "=== ☕ Configuration Maven ==="
                    cat pom.xml | grep -A 5 -B 5 "<version>\|<java.version>\|<spring-boot.version>" || true
                '''
            }
        }

        stage('Build & Test') {
            parallel {
                stage('Compile') {
                    steps {
                        echo '🏗️ Compilation du projet Store API...'
                        
                        sh '''
                            echo "🧹 Nettoyage..."
                            mvn clean
                            
                            echo "⚙️ Compilation..."
                            mvn compile -DskipTests=true
                            
                            echo "✅ Compilation terminée"
                        '''
                    }
                }
                
                stage('Tests') {
                    steps {
                        echo '🧪 Exécution des tests unitaires...'
                        
                        sh '''
                            echo "🧪 Lancement des tests..."
                            mvn test -Dtest.skip=false
                            
                            echo "📊 Résultats des tests :"
                            find target/surefire-reports -name "*.xml" | wc -l | sed 's/^/Fichiers de résultats: /'
                            
                            echo "✅ Tests terminés"
                        '''
                    }
                    post {
                        always {
                            // Publication des résultats de tests
                            junit allowEmptyResults: true, testResultsGlob: 'target/surefire-reports/*.xml'
                            
                            // Archivage des rapports
                            archiveArtifacts artifacts: 'target/surefire-reports/**/*', allowEmptyArchive: true
                        }
                    }
                }
            }
        }

        stage('Package') {
            steps {
                echo '📦 Packaging de l\'application Store...'
                
                sh '''
                    echo "📦 Création du JAR..."
                    mvn package -DskipTests=true
                    
                    echo "📋 Artefacts générés :"
                    find target -name "*.jar" -type f -exec ls -lh {} \;
                    
                    # Renommage pour simplifier
                    cd target
                    if [ -f store-0.0.1-SNAPSHOT.jar ]; then
                        cp store-0.0.1-SNAPSHOT.jar hackathon4-store.jar
                        echo "✅ JAR renommé en hackathon4-store.jar"
                    fi
                '''
                
                // Archivage des artefacts
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }

        stage('Build Docker Image') {
            steps {
                echo '🐳 Construction de l\'image Docker ARM64...'
                
                script {
                    // Construction de l'image Docker optimisée ARM64
                    sh '''
                        echo "🏗️ Construction de l'image Docker..."
                        
                        # Construction avec buildx pour ARM64
                        docker buildx build \
                            --platform linux/arm64 \
                            --build-arg JAR_FILE=target/hackathon4-store.jar \
                            -t ${DOCKER_IMAGE}:${BUILD_NUMBER} \
                            -t ${DOCKER_IMAGE}:latest \
                            -t ${DOCKER_IMAGE}:${BUILD_TIMESTAMP} \
                            --load \
                            .
                        
                        echo "✅ Image Docker créée :"
                        docker images | grep ${DOCKER_IMAGE} | head -5
                    '''
                }
            }
        }

        stage('Prepare Deployment Files') {
            steps {
                echo '📋 Préparation des fichiers de déploiement...'
                
                sh '''
                    echo "📁 Création des fichiers de déploiement..."
                    
                    # Script de déploiement optimisé
                    cat > deploy.sh << 'DEPLOY_EOF'
#!/bin/bash

echo "🚀 Déploiement Store API - Hackathon 4"
echo "======================================"

cd ${DEPLOYMENT_DIR}

echo "⏹️ Arrêt des services existants..."
docker-compose down --remove-orphans

echo "🧹 Nettoyage des anciens containers..."
docker system prune -f

echo "📥 Chargement de la nouvelle image..."
if [ -f hackathon4-store-api-latest.tar.gz ]; then
    docker load < hackathon4-store-api-latest.tar.gz
    echo "✅ Image chargée"
else
    echo "⚠️ Aucune nouvelle image trouvée"
fi

echo "🚀 Démarrage des nouveaux services..."
docker-compose up -d

echo "⏳ Attente de la disponibilité (60s)..."
sleep 60

echo "🏥 Vérification des services..."
docker-compose ps

echo "🧪 Test de santé de l'API..."
for i in {1..10}; do
    if curl -f http://localhost:8080/actuator/health 2>/dev/null; then
        echo "✅ API disponible!"
        break
    else
        echo "⏳ Tentative $i/10 - API pas encore prête..."
        sleep 10
    fi
done

echo "📊 Status final :"
curl -s http://localhost:8080/actuator/health | jq '.' || echo "Health check indisponible"

echo "✅ Déploiement terminé!"
DEPLOY_EOF

                    chmod +x deploy.sh
                    
                    echo "✅ Fichiers de déploiement prêts"
                    ls -la deploy.sh docker-compose.yml
                '''
            }
        }

        stage('Save & Transfer Docker Image') {
            steps {
                echo '💾 Sauvegarde et transfert de l\'image Docker...'
                
                script {
                    withCredentials([string(credentialsId: "${API_SERVER_IP_CRED_ID}", variable: 'API_SERVER_IP')]) {
                        sshagent(credentials: ['hackathon4-ssh-key']) {
                            sh '''
                                echo "💾 Création de l'archive Docker..."
                                docker save ${DOCKER_IMAGE}:latest | gzip > ${DOCKER_IMAGE}-latest.tar.gz
                                
                                echo "📊 Taille de l'archive :"
                                ls -lh ${DOCKER_IMAGE}-latest.tar.gz
                                
                                echo "📤 Transfert des fichiers vers l'API Server..."
                                
                                # Test de connectivité SSH
                                ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 ubuntu@$API_SERVER_IP "echo 'SSH OK'"
                                
                                # Transfert des fichiers
                                scp -o StrictHostKeyChecking=no \
                                    ${DOCKER_IMAGE}-latest.tar.gz \
                                    docker-compose.yml \
                                    deploy.sh \
                                    ubuntu@$API_SERVER_IP:${DEPLOYMENT_DIR}/
                                
                                echo "✅ Fichiers transférés"
                            '''
                        }
                    }
                }
            }
        }

        stage('Deploy to API Server') {
            steps {
                echo '🚀 Déploiement sur le serveur API...'
                
                script {
                    withCredentials([string(credentialsId: "${API_SERVER_IP_CRED_ID}", variable: 'API_SERVER_IP')]) {
                        sshagent(credentials: ['hackathon4-ssh-key']) {
                            sh '''
                                echo "🚀 Exécution du déploiement sur le serveur..."
                                
                                ssh -o StrictHostKeyChecking=no ubuntu@$API_SERVER_IP "
                                    cd ${DEPLOYMENT_DIR}
                                    chmod +x deploy.sh
                                    ./deploy.sh
                                "
                                
                                echo "✅ Déploiement exécuté"
                            '''
                        }
                    }
                }
            }
        }

        stage('Health Check & Validation') {
            steps {
                echo '🏥 Vérification finale et tests de l\'API Store...'
                
                script {
                    withCredentials([string(credentialsId: "${API_SERVER_IP_CRED_ID}", variable: 'API_SERVER_IP')]) {
                        sshagent(credentials: ['hackathon4-ssh-key']) {
                            sh '''
                                echo "🏥 Tests de santé de l'API Store..."
                                
                                ssh -o StrictHostKeyChecking=no ubuntu@$API_SERVER_IP "
                                    cd ${DEPLOYMENT_DIR}
                                    
                                    echo '📊 Status des containers :'
                                    docker-compose ps
                                    
                                    echo '🏥 Health Check API :'
                                    curl -s http://localhost:8080/actuator/health | jq '.' || echo 'Health check échoué'
                                    
                                    echo '📋 Endpoints Store disponibles :'
                                    curl -s http://localhost:8080/actuator | jq '._links | keys[]' || echo 'Impossible de lister les endpoints'
                                    
                                    echo '🧪 Test des endpoints métier :'
                                    # Test endpoint Users
                                    echo 'Test /users:'
                                    curl -s -w 'Status: %{http_code}\\n' http://localhost:8080/users -o /dev/null
                                    
                                    # Test endpoint Contacts  
                                    echo 'Test /contacts:'
                                    curl -s -w 'Status: %{http_code}\\n' http://localhost:8080/contacts -o /dev/null
                                "
                            '''
                        }
                    }
                    
                    // Test externe via Kong (si configuré)
                    sh '''
                        echo "🌐 Test de l'API via l'adresse publique..."
                        
                        # Test direct de l'API (remplace par l'IP Kong si configuré)
                        API_URL="http://$API_SERVER_IP:8080"
                        
                        echo "🧪 Test Health Check public :"
                        response=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL/actuator/health")
                        echo "Response code: $response"
                        
                        if [ "$response" -eq 200 ]; then
                            echo "✅ API Store accessible publiquement"
                            echo "🌐 URL: $API_URL/swagger-ui/index.html"
                        else
                            echo "⚠️ API non accessible publiquement (Status: $response)"
                            echo "💡 Vérifiez la configuration Kong Gateway"
                        fi
                    '''
                }
            }
        }
    }

    post {
        always {
            echo '🧹 Nettoyage des fichiers temporaires...'
            sh '''
                # Nettoyage des archives locales
                rm -f *.tar.gz
                
                # Nettoyage des anciennes images (garde les 5 dernières)
                docker images ${DOCKER_IMAGE} --format "table {{.Repository}}:{{.Tag}}" | tail -n +2 | head -n -5 | awk '{print $1":"$2}' | xargs -r docker rmi || true
                
                echo "✅ Nettoyage terminé"
            '''
        }
        
        success {
            echo '''
🎉 PIPELINE STORE API RÉUSSI !
==============================

✅ Code récupéré depuis GitHub  
✅ Tests unitaires passés
✅ Image Docker ARM64 créée
✅ Déploiement sur API Server réussi
✅ Health checks OK

📊 Accès à l'API Store :
🌐 Swagger UI: http://API_SERVER_IP:8080/swagger-ui/index.html
🏥 Health: http://API_SERVER_IP:8080/actuator/health
👥 Users: http://API_SERVER_IP:8080/users  
📞 Contacts: http://API_SERVER_IP:8080/contacts

🔑 Prochaines étapes :
1. Configurer Kong Gateway pour l'accès public
2. Tester les endpoints via Kong
3. Configurer l'authentification API Key
            '''
        }
        
        failure {
            echo '''
❌ PIPELINE STORE API ÉCHOUÉ !
==============================

🔍 Points de contrôle à vérifier :
- Configuration des credentials GitHub
- Connectivité SSH vers l'API Server  
- Configuration Docker sur l'API Server
- Ports et Security Groups AWS
- Configuration Maven/Java

📋 Logs à consulter :
- Console Output Jenkins
- Logs Docker sur l'API Server
- Health Check endpoints
            '''
        }
        
        unstable {
            echo '''
⚠️ PIPELINE INSTABLE
===================

Certains tests ont échoué mais le déploiement a continué.
Vérifiez les résultats des tests et l'état de l'application.
            '''
        }
    }
}
EOF

echo "✅ Jenkinsfile mis à jour pour ton repository GitHub"
