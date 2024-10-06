FROM jenkins/jenkins:lts

USER root

# Update the package list and install prerequisites
RUN apt update -y && \
    apt install -y wget apt-transport-https gnupg lsb-release && \
    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | apt-key add - && \
    echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | tee -a /etc/apt/sources.list.d/trivy.list && \
    apt update -y && \
    apt install -y trivy && \
    echo "Trivy version:" && trivy --version

USER jenkins
