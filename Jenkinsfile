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
        }   

        stage('PIT Mutation Test') {
            steps {
              sh "mvn org.pitest:pitest-maven:mutationCoverage"
            }
        }   
        
       stage('SAST - Sonarqube') {
            steps {
              withSonarQubeEnv('SonarQube')  {
                sh "mvn clean verify sonar:sonar -Dsonar.projectKey=numeric-app -Dsonar.host.url=http://20.229.193.34:9000" // -Dsonar.login=squ_c591f1e94ba5df1f36b1b999eaae286fa6737c48"
              }
              timeout(time: 2, unit: 'MINUTES') {
                script {
                  waitForQualityGate abortPipeline: true
                }
              }
            }
        }  

       stage('Vulnerabitilites Scan') {
            steps {
              parallel (

                "Dependency Check" : {
                  // sh "mvn dependency-check:check"
                  echo "mvn dependency-check:check"
                  //commented because still not done R&D to find appropriate parent spring boot dependencies
                },

                "Trivy Scans Base Image" : {
                  sh "bash trivy_scan_base_image.sh"
                },
                                
                "OPA Conftest Scans our Dockerfile" : {
                  sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-docker-security.rego Dockerfile'
                }

              )
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
    post {
      always {
        junit 'target/surefire-reports/*.xml'
        jacoco execPattern: 'target/jacoco.exec'
        pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
        dependencyCheckPublisher pattern:"target/dependency-check-report.xml"
      }
    }
}