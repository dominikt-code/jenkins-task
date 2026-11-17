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

        stage('Docker build') {
            steps {
                sh 'docker build -t task-api:local .'
        }

         
    }
    }

    post {
        always {
            echo "Pipeline finished for ENV=${params.ENV}, BUILD_VERSION=${params.BUILD_VERSION}"
            archiveArtifacts artifacts: "junit.xml", allowEmptyArchive: true
        }
        success {
            echo "Build completed successfully"
        }
        failure {
            echo "Build failed - check logs"
        }
    }
}