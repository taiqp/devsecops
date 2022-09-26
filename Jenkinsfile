pipeline {
  agent any

  stages {
      //  stage('Git version') {
      //       steps {
      //         sh "git --version"
      //       }
      //   }   
      //  stage('Jenkins version') {
      //       steps {
      //         sh "jenkins --version"
      //       }
      //   }   
      //  stage('Docker version') {
      //       steps {
      //         sh "docker version"
      //       }
      //   }   
      //  stage('Kubernetes version') {
      //       steps {
      //         withKubeConfig([credentialsId: 'kubeconfig']) {
      //           sh "kubectl version --short "
      //         }              
      //       }
      //   }   
       stage('Maven build') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar'
            }
        }   

       stage('Unit Tests - JUnit and Jacoco') {
            steps {
              sh "mvn test"
            }
            post {
              always {
                junit 'target/surefire-reports/*.xml'
                jacoco execPattern: 'target/jacoco.exec'
              }
            }
        }   


    }
}