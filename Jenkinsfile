pipeline {
  agent any

  stages {
       stage('Git version') {
            steps {
              sh "git --version"
            }
        }   
       stage('Jenkins version') {
            steps {
              sh "jenkins --version"
            }
        }   
       stage('Docker version') {
            steps {
              sh "docker version"
            }
        }   
       stage('Kubernetes version') {
            steps {
              sh "kubectl version --short "
            }
        }   
    }
}