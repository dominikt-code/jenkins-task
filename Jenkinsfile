pipeline {
    agent{ label "ci" }

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    parameters {
        choice(name: "ENV", choices: ["dev", "test"], description: "Środowisko docelowe")
        booleanParam(name: "RUN_TESTS", defaultValue: true, description: "Czy odpalić testy")
        string(name: "BUILD_VERSION", defaultValue: "1.0.0", description: "Wersja builda")
    }

    stages {
        stage("Checkout") {
            steps {
                checkout scm
            }
        }

        stage("Install dependencies") {
            steps {
                sh "npm install"
            }
        }

        stage("Run tests") {
            when {
                expression {
                    params.RUN_TESTS == true
                }
            }
            steps {
            echo "Building version ${params.BUILD_VERSION} for env ${params.ENV}"
            sh "npm test" 
            }
        }

        stage("Docker build") {
            steps {
                sh "docker build -t task-api:local ."
            }
        }

        stage("Docker run") {
            steps {
                sh "docker rm -f task-api-test || true"
                sh "docker run -d --name task-api-test -p 3000:3000 task-api:local"
                sh "sleep 3"
                sh 'CONTAINER_IP=$(docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" task-api-test); curl --retry 5 --retry-delay 2 -f http://$CONTAINER_IP:3000/healthz'
            }
        }

        stage("Use credential") {
            steps {
                withCredentials([string(credentialsId: "demo-api-key-123", variable: "API_KEY")]) {
                    sh 'docker run --rm -e API_KEY=$API_KEY task-api:local node -e "console.log(process.env.API_KEY ? \'API_KEY ustawiony\' : \'brak\')"'
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline finished for ENV=${params.ENV}, BUILD_VERSION=${params.BUILD_VERSION}"
            archiveArtifacts artifacts: "junit.xml", allowEmptyArchive: true
            sh "docker rm -f task-api-test || true"
        }
        success {
            echo "Build completed successfully"
        }
        failure {
            echo "Build failed - check logs"
        }
    }
}