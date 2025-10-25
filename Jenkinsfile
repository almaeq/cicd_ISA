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

        stage('TEST: Verificar Credencial Docker') {
                    steps {
                        // Aquí usamos el MISMO ID de credencial que usa tu etapa 'publish docker'
                        // Asumo que se llama 'dockerhub-login', ajústalo si es diferente.
                        withCredentials([string(credentialsId: 'dockerhub-login', variable: 'DOCKER_PASS')]) {

                            // Intentamos iniciar sesión directamente en Docker Hub
                            // Usamos tu usuario 'almaeq' y la contraseña de la credencial
                            sh 'echo $DOCKER_PASS | docker login -u almaeq --password-stdin'
                        }
                    }
                }

        // --- La etapa 'publish docker' AHORA ESTÁ DENTRO del bloque .inside() ---
        stage('publish docker') {
                    steps {
                        // 1. Usamos 'usernamePassword' para obtener AMBOS, usuario y pass
                        // 2. Asignamos la credencial a las variables de entorno que el pom.xml espera
                        withCredentials([usernamePassword(credentialsId: 'dockerhub-login',
                                                         usernameVariable: 'DOCKER_REGISTRY_USER',
                                                         passwordVariable: 'DOCKER_REGISTRY_PWD')]) {

                            // 3. Ejecutamos el comando LIMPIO, sin argumentos -D
                            //    Jib ahora leerá las variables de entorno automáticamente
                            // 4. Añadimos -DskipTests para evitar el error del servidor de correo
                            sh './mvnw -ntp -DskipTests jib:build'
                        }
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
