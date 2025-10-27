# Usamos una imagen base oficial de Jenkins (LTS con Java 17)
FROM jenkins/jenkins:lts-jdk17

# Cambiamos al usuario root para poder instalar paquetes
USER root

# Instalamos los paquetes necesarios y el cliente oficial de Docker
RUN apt-get -y update && apt-get install -y lsb-release curl
RUN curl -fsSL https://download.docker.com/linux/$(. /etc/os-release && echo "$ID")/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/$(. /etc/os-release && echo "$ID") \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update && apt-get install -y docker-ce-cli

# Agregar usuario jenkins al grupo docker
RUN groupadd -f docker && usermod -aG docker jenkins

# Volvemos al usuario 'jenkins' por seguridad
USER jenkins
