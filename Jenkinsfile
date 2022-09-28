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

       stage('SAST - Sonarqube') {
            steps {
              sh "mvn clean verify sonar:sonar -Dsonar.projectKey=numeric-app -Dsonar.host.url=http://20.229.193.34:9000 -Dsonar.login=sqp_04f50064f13d4621a968d761d01317493a345547"
            }
            post {
              always {
                junit 'target/surefire-reports/*.xml'
                jacoco execPattern: 'target/jacoco.exec'
              }
            }
        }   

        stage('PIT Mutation Test') {
            steps {
              sh "mvn org.pitest:pitest-maven:mutationCoverage"
            }
            post {
              always {
                pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
              }
            }
        }   

       stage('Docker build and push') {
            steps {
              withDockerRegistry([url:"", credentialsId: "dockerhub"]) {
                // sh "docker version"
                sh "printenv"
                sh 'docker build -t taiqp/numeric-app:1.""$BUILD_ID"" .'
                sh 'docker push taiqp/numeric-app:1.""$BUILD_ID""'
              }
            }
        }   

       stage('Kubernetes deploy - Dev') {
            steps {
              withKubeConfig([credentialsId: 'kubeconfig']) {
                sh "sed -i 's#replace#taiqp/numeric-app:1.${BUILD_ID}#g' k8s_deployment_service.yaml"
                sh "kubectl apply -f k8s_deployment_service.yaml"
              }              
            }
        }   
    }
}