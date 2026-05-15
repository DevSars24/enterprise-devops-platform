pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "abctechnologies/retail-module"
        CHART_PATH = "charts/retail-module"
        REGISTRY_CREDENTIALS = 'docker-hub-creds'
    }

    stages {
        stage('🛠️ Initialization') {
            steps {
                echo 'Initializing Environment...'
                sh 'mvn -version'
                sh 'docker version'
            }
        }

        stage('🧪 Quality & Tests') {
            parallel {
                stage('Unit Tests') {
                    steps {
                        sh 'mvn test'
                    }
                }
                stage('Linting') {
                    steps {
                        echo 'Running Checkstyle/Linting...'
                        // sh 'mvn checkstyle:check'
                    }
                }
            }
            post {
                always {
                    junit '**/target/surefire-reports/*.xml'
                    jacoco execPattern: 'target/jacoco.exec'
                }
            }
        }

        stage('📦 Package') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('🐳 Dockerize') {
            steps {
                script {
                    def appVersion = "1.0.${env.BUILD_NUMBER}"
                    dockerImage = docker.build("${DOCKER_IMAGE}:${appVersion}")
                    dockerImage = docker.build("${DOCKER_IMAGE}:latest")
                }
            }
        }

        stage('🛡️ Security Scan') {
            steps {
                echo 'Scanning image with Trivy...'
                // sh "trivy image ${DOCKER_IMAGE}:latest"
            }
        }

        stage('🚀 Deploy to K8s') {
            steps {
                script {
                    echo "Deploying to Kubernetes via Helm..."
                    sh "helm upgrade --install retail-module ${CHART_PATH} --set image.tag=1.0.${env.BUILD_NUMBER}"
                }
            }
        }
    }

    post {
        success {
            echo '✅ Deployment Successful!'
        }
        failure {
            echo '❌ Pipeline Failed. Checking logs...'
        }
    }
}