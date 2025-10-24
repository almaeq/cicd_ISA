#!/usr/bin/env groovy

node {
    stage('checkout') {
        // Clona el repositorio. Asumimos que mvnw, pom.xml, etc., están en la raíz.
        checkout scm
    }

    // --- Eliminamos la línea gitlabCommitStatus('build') { ---

    docker.image('jhipster/jhipster:v8.11.0').inside('-u jhipster -e MAVEN_OPTS="-Duser.home=./"') {

        // --- Comandos ejecutados dentro del contenedor y en la raíz del workspace ---

        stage('check java') {
            sh "java -version"
        }

        stage('clean') {
            sh "chmod +x mvnw" // Aseguramos permisos
            sh "./mvnw -ntp clean -P-webapp"
        }
        stage('nohttp') {
            sh "./mvnw -ntp checkstyle:check"
        }

        stage('install tools') {
            sh "./mvnw -ntp com.github.eirslett:frontend-maven-plugin:install-node-and-npm@install-node-and-npm"
        }

        stage('npm install') {
            // Ejecutando npm directamente
            sh "npm install"
        }

        stage('backend tests') {
            try {
                sh "./mvnw -ntp verify -P-webapp"
            } catch(err) {
                throw err
            } finally {
                junit '**/target/surefire-reports/TEST-*.xml,**/target/failsafe-reports/TEST-*.xml'
            }
        }

        stage('frontend tests') {
            try {
               // Ya no es necesario 'npm install' si se hizo en la etapa anterior
               sh "npm test"
            } catch(err) {
                throw err
            } finally {
                junit '**/target/test-results/TESTS-results-jest.xml'
            }
        }

        stage('packaging') {
            sh "./mvnw -ntp verify -P-webapp -Pprod -DskipTests"
            // El artefacto ahora estará en target/*.jar
            archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
        }

        // --- La etapa 'publish docker' AHORA ESTÁ DENTRO del bloque .inside() ---
        stage('publish docker') {
            withCredentials([usernamePassword(credentialsId: 'dockerhub-login', passwordVariable: 'DOCKER_REGISTRY_PWD', usernameVariable: 'DOCKER_REGISTRY_USER')]) {
                // Jib usa el pom.xml, que está en la raíz del workspace dentro del contenedor
                sh "./mvnw -ntp jib:build -Ddocker.username=${DOCKER_REGISTRY_USER} -Ddocker.password=${DOCKER_REGISTRY_PWD}"
            }
        }

    } // <- Cierre del docker.image(...).inside(...)

    // --- Eliminamos la llave de cierre correspondiente a gitlabCommitStatus ---

       def dockerImage
       stage('publish docker') {
       withCredentials([usernamePassword(credentialsId: 'dockerhub-login', passwordVariable:
       'DOCKER_REGISTRY_PWD', usernameVariable: 'DOCKER_REGISTRY_USER')]) {
       sh "./mvnw -ntp jib:build"
        }
    }
}
