# A DevOps example project with many Security Steps

## Description

The system has 02 components:
- One NodeJS service, available on Docker Hub: taiqp/node-service, which plays one function: plus 1 to the number on url. To run it, we just need to deploy a deployment and a service on K8s cluster (open port: 5000)
`docker run -p 5000:5000 taiqp/node-service:v1`
Function: +1 for any call

http://node-service:5000/plusone

- A Java application to call NodeJS service on port 5000. 

The pipeline focus on building steps for Java application

## Steps in Jenkins pipeline
01. Fetch GitHub
The pipeline does not have a fetching GitHub repository, we need to set a webhook to call Jenkins every push.

02. Maven build
sh "mvn clean package -DskipTests=true"
archive 'target/*.jar'

03. Unit Test, and using JaCoco to see how many code lines were tested
sh "mvn test"
jacoco execPattern: 'target/jacoco.exec'

04. PIT Mutation Test: To check the Unit Tests
 sh "mvn org.pitest:pitest-maven:mutationCoverage"
 pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
 
05. Do SAST using Sonarqube, then Jenkins wait for Quality Gate to sendback via webhook
sh "mvn clean verify sonar:sonar -Dsonar.projectKey=numeric-app -Dsonar.host.url=http://20.229.193.34:9000" // -Dsonar.login=squ_c591f1e94ba5df1f36b1b999eaae286fa6737c48"
timeout(time: 2, unit: 'MINUTES') {
  script {
    waitForQualityGate abortPipeline: true
  }
}

06. Check some vulnerabilities:
  06.1. Dependency-check plugin to check any outdated dependencies
                    echo "mvn dependency-check:check"

  06.2. Trivy to scan the base image on Dockerfile for any critical CVE
                    sh "bash trivy_scan_base_image.sh"
docker run --rm -v $WORKSPACE:/root/.cache/ bitnami/trivy:latest -q image --exit-code 0 --severity HIGH --light $dockerImageName
docker run --rm -v $WORKSPACE:/root/.cache/ bitnami/trivy:latest -q image --exit-code 1 --severity CRITICAL --light $dockerImageName

  06.3. OPA Conftest to scan the Dockerfile before build (using rego language file)
                   sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy OPA_Conftest.rego Dockerfile'

07. Build Docker image & push to Dockerhub
                sh 'docker build -t taiqp/numeric-app:1.""$BUILD_ID"" .'
                sh 'docker push taiqp/numeric-app:1.""$BUILD_ID""'

08. Scan vulnerabilities before deploying on K8s Dev
  * OPA scan yaml files for any NodePort, or any root-running security context
              sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy OPA_Conftest_Yaml_test.rego k8s_deployment_service.yaml'
  
  * Kubesec: Call API kubesec to scan the yaml file
  scan_result=$(curl -sSX POST --data-binary @"k8s_deployment_service.yaml" https://v2.kubesec.io/scan)

  * Trivy: scan own image before deploying for any critical vulnerablities. Here it found one, but need to update pom.xml, which is out of scope of DevOps engineer.

09. Intergration Test: check the link with NodePort
