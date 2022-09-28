#Sonarqube for SAST
docker run -d --name=sonarqube -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true -p 9000:9000 sonarqube:latest

#Trivy for Image scan
docker run --rm -v $HOME/trivy/caches:/root/.cache/ aquasec/trivy image mysql:5.7.25
docker run --rm -v $HOME/trivy/caches:/root/.cache/ aquasec/trivy --severity CRITICAL image mysql:5.7.25

#OPA Conftest
