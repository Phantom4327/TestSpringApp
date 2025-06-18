// Jenkinsfile
pipeline {
    agent any

    tools {
        jdk 'jdk-11'
        maven 'Maven-3.8.6'
    }

    environment {
        // --- 请根据你的环境修改以下变量 ---
        DOCKER_HUB_CREDENTIALS_ID = 'dockerhub-credentials' // Jenkins 中 Docker Hub 凭据的 ID
        DOCKER_HUB_USERNAME     = 'Phantom4327' // 你的 Docker Hub 用户名
        IMAGE_NAME              = "${DOCKER_HUB_USERNAME}/k8s-test-app"
        KUBECONFIG_CREDENTIALS_ID = 'kubeconfig-credentials' // Jenkins 中 Kubeconfig 凭据的 ID
        K8S_DEPLOYMENT_FILE     = 'deployment.yml'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Package') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                script {
                    def imageTag = "${env.BUILD_NUMBER}"
                    def fullImageName = "${IMAGE_NAME}:${imageTag}"

                    // 构建镜像
                    sh "docker build -t ${fullImageName} ."

                    // 登录并推送镜像
                    withCredentials([usernamePassword(credentialsId: DOCKER_HUB_CREDENTIALS_ID, usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                        sh "docker login -u ${USER} -p ${PASS}"
                        sh "docker push ${fullImageName}"
                        sh "docker logout"
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    def imageTag = "${env.BUILD_NUMBER}"
                    def fullImageName = "${IMAGE_NAME}:${imageTag}"

                    withCredentials([file(credentialsId: KUBECONFIG_CREDENTIALS_ID, variable: 'KUBECONFIG_FILE')]) {
                        sh """
                            export KUBECONFIG=\$KUBECONFIG_FILE

                            # 使用 sed 命令动态替换 YAML 文件中的镜像地址
                            sed -i 's|image: .*|image: ${fullImageName}|g' ${K8S_DEPLOYMENT_FILE}

                            # 应用更新后的 YAML 文件
                            kubectl apply -f ${K8S_DEPLOYMENT_FILE}

                            # 检查部署状态
                            kubectl rollout status deployment/k8s-test-app-deployment
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'CI/CD Pipeline finished successfully!'
        }
    }
}