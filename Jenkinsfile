pipeline {
    agent none

    parameters {
        choice(name: "ENV", choices: ["dev", "prod"], description: "Środowisko docelowe")
    }

    environment {
        ECR_REPO = "551897326955.dkr.ecr.eu-central-1.amazonaws.com/task-api"
    }

    stages {
        stage("Checkout") {
            agent { label "ci" }
            steps {
                checkout scm
            }
        }

        stage("Install dependencies") {
            agent { label "ci" }
            steps {
                sh "npm install"
            }
        }

        stage("Run tests") {
            agent { label "ci" }
            steps {
                sh "npm test"
            }
        }

        stage("Docker build & push") {
            agent { label "ci" }
            steps {
                withCredentials([
                    string(credentialsId: "AccessKeyId", variable: "AWS_ACCESS_KEY_ID"),
                    string(credentialsId: "SecretAccessKey", variable: "AWS_SECRET_ACCESS_KEY")
                ]) {
                    sh "docker build -t task-api:${BUILD_NUMBER} ."
                    sh "aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin ${ECR_REPO}"
                    sh "docker tag task-api:${BUILD_NUMBER} ${ECR_REPO}:${BUILD_NUMBER}"
                    sh "docker push ${ECR_REPO}:${BUILD_NUMBER}"
                }
            }
        }

        stage("Terraform init") {
            agent { label "infrastructure" }
            steps {
                withCredentials([
                    string(credentialsId: "AccessKeyId", variable: "AWS_ACCESS_KEY_ID"),
                    string(credentialsId: "SecretAccessKey", variable: "AWS_SECRET_ACCESS_KEY")
                ]) {
                    sh "terraform -chdir=terraform/app init"
                }
            }
        }

        stage("Terraform plan") {
            agent { label "infrastructure" }
            steps {
                withCredentials([
                    string(credentialsId: "AccessKeyId", variable: "AWS_ACCESS_KEY_ID"),
                    string(credentialsId: "SecretAccessKey", variable: "AWS_SECRET_ACCESS_KEY")
                ]) {
                    sh "terraform -chdir=terraform/app workspace select -or-create ${params.ENV}"
                    sh "terraform -chdir=terraform/app plan -var='container_image=${ECR_REPO}:${BUILD_NUMBER}' -out=tfplan"
                }
            }
        }

        stage("Approval for prod") {
            when { expression { params.ENV == "prod" } }
            steps {
                input message: "Zatwierdź deployment na PROD?"
            }
        }

        stage("Terraform apply") {
            agent { label "infrastructure" }
            steps {
                withCredentials([
                    string(credentialsId: "AccessKeyId", variable: "AWS_ACCESS_KEY_ID"),
                    string(credentialsId: "SecretAccessKey", variable: "AWS_SECRET_ACCESS_KEY")
                ]) {
                    sh "terraform -chdir=terraform/app apply -auto-approve tfplan"
                }
            }
        }

        stage("Health check") {
            agent { label "ci" }
            steps {
                withCredentials([
                    string(credentialsId: "AccessKeyId", variable: "AWS_ACCESS_KEY_ID"),
                    string(credentialsId: "SecretAccessKey", variable: "AWS_SECRET_ACCESS_KEY")
                ]) {
                    script {
                        env.APP_URL = sh(script: "terraform -chdir=terraform/app output -raw alb_dns_name", returnStdout: true).trim()
                    }
                    sh "curl --retry 5 --retry-delay 5 -f http://${env.APP_URL}/health"
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline finished for ENV=${params.ENV}"
        }
        success {
            echo "Build completed successfully"
        }
        failure {
            echo "Build failed - check logs"
        }
    }
}