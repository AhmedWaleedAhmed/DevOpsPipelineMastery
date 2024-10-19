# Seamless CI/CD Pipeline Setup for Cloud Applications

## Introduction
__Seamless CI/CD Pipeline Setup for Cloud Applications__ automates the creation and configuration of cloud infrastructure using Terraform and Ansible. This project sets up a Kubernetes cluster and integrates key DevOps tools like SonarQube, Nexus, Jenkins, Prometheus, and Grafana.

With a fully automated CI/CD pipeline, the project streamlines code updates, continuous testing, and real-time monitoring, ensuring efficient and reliable deployments. This setup enables teams to manage infrastructure as code, promoting rapid application delivery and scalability in cloud environments.

---

## Table of Contents
1. [Architecture](#architecture)
2. [Data Flow](#data-flow)
3. [Technology Stack](#technology-stack)
4. [Infrastructure Setup](#infrastructure-setup)
5. [CI/CD Pipeline](#ci-cd-pipeline)
6. [Monitoring Setup](#monitoring-setup)
7. [Usage Instructions](#usage-instructions)

---
## Architecture

### Architecture Diagram Created with Draw.io
![Architecture Diagram](images/architecture-diagram.svg)

### Architecture Diagram Generated with Terraform Graph
![Terraform Graph](images/terraform-graph.png)
---
## Data Flow
This architecture integrates **Terraform**, **AWS**, **Ansible**, **Kubernetes**, **Jenkins**, **SonarQube**, **Nexus**, **Prometheus**, and **Grafana** to automate CI/CD pipelines and system monitoring.

#### Components:

- **Terraform:** Builds AWS infrastructure (VPC, subnets, route tables, EC2, IGW, security groups).
- **AWS:** Hosts all components within the created infrastructure.
- **Ansible:** Configures servers:
  - Sets up Kubernetes master and worker nodes, initializes `kubeadm`, and configures the network.
  - Installs Prometheus, Grafana, and the Black-box exporter for monitoring.
  - Sets up Nexus (artifact repository) and SonarQube (code analysis) via Docker.
  - Configures Jenkins, installs essential plugins, tools (Docker, kubectl, Trivy), and automates Kubernetes authentication.
- **Kubernetes:** Orchestrates containerized workloads; Jenkins deploys apps to the cluster.
- **Jenkins:** Automates the CI/CD pipeline, integrates with SonarQube for code analysis, pushes artifacts to Nexus, deploys apps to Kubernetes, and integrates with Prometheus for monitoring.
- **Prometheus & Grafana:** Prometheus collects system metrics; Grafana visualizes real-time performance data.
- **Black-box Exporter:** Monitors external website availability for Grafana visualization.

---

## Technology Stack
List the tools and technologies used in the project, e.g.:
- **Terraform** for infrastructure as code (IaC)
- **Ansible** for configuration management
- **Kubernetes** for container orchestration
- **Jenkins** for CI/CD pipeline automation
- **SonarQube**, **Nexus**, **Prometheus**, **Grafana** for DevOps monitoring and code quality

---

## Infrastructure Setup
### Terraform Configuration
**Terraform** provisions the infrastructure on AWS, creating a **VPC**, public **subnet**, **routing table**, **Internet Gateway (IGW)**, **security groups**, and **EC2 instances**.

Each **EC2 instance** is configured based on its role: Kubernetes master, worker nodes, Jenkins, Nexus, SonarQube, Prometheus, and Grafana.

### Ansible Playbooks
**Ansible** is used for configuring the servers, setting up the Kubernetes cluster (master and workers), and deploying all necessary services like Jenkins, Prometheus, Grafana, Nexus, and SonarQube.

---

## CI/CD Pipeline
### Jenkins Pipeline Overview

The Jenkins pipeline automates the entire CI/CD process for a Java-based application, covering everything from code checkout to deployment in Kubernetes. Below is an overview of the key stages:

1. **Tools Configuration:**  
   Uses **JDK 17**, **Maven 3**, and **SonarQube Scanner** for building and analyzing the code.

2. **Git Checkout:**  
   Pulls the source code from the `main` branch of the GitHub repository.

3. **Compilation & Testing:**  
   Compiles the code and runs unit tests using **Maven**.

4. **Security Scans:**  
   Scans both the file system and Docker images for vulnerabilities using **Trivy**.

5. **SonarQube Analysis:**  
   Performs code quality analysis using **SonarQube** and checks for code issues.

6. **Artifact Publishing:**  
   Publishes the build artifacts (e.g., JAR files) to **Nexus**.

7. **Docker Image Build & Push:**  
   Builds a **Docker** image and pushes it to a registry.

8. **Kubernetes Deployment:**  
   Deploys and updates the application in a **Kubernetes** cluster.

9. **Verification:**  
   Verifies that the deployment is successful by checking the **Pods** and **Services**.

This pipeline automates code management, security checks, artifact storage, and deployment, ensuring a streamlined and efficient CI/CD workflow.

![Ansible Graph](images/jenkins-pipeline-flow.svg)

---

## Monitoring Setup
This project employs Prometheus and Grafana to monitor infrastructure performance and reliability.

### Components

- **Prometheus**: An open-source toolkit for collecting and storing metrics as time series data.
- **Grafana**: A visualization platform that displays metrics from Prometheus on customizable dashboards.
- **Black-Box Exporter**: Monitors website availability and performance through HTTP(s) checks.
- **Node Exporter**: Collects system metrics (CPU, memory, disk) from the Jenkins node.
- **Jenkins Exporter Plugin**: Exports Jenkins metrics, including job performance and build times, to Prometheus.

---

## Usage Instructions
### Prerequisites

Before you begin, ensure you have the following tools and environment set up:

- **Git**: To clone the repository, make sure you have Git installed.  
- **Ansible**: Required for deploying the infrastructure and running playbooks.
- **Terraform**: Needed for infrastructure management.
- **AWS Credentials**: Create an AWS access key and secret key to authenticate your Terraform configurations.

### Steps to deploy the infrastructure and run the playbooks
1. **Navigate to the Terraform directory:**
```bash
  cd terraform
```
2. **Initialize Terraform:**
```bash
  terraform init
```
3. **Apply the configuration:**
```bash
  terraform apply
```
4. **Navigate to the Ansible directory:**
```bash
  cd ../ansible
```
5. **Run the playbook to set up Nexus:**
```bash
  ansible-playbook -i inventory.yml playbooks/nexus_setup.yml
```
6. **Open Nexus:**
```bash
http://<your_nexus_server_IP>:8081
```
7. **login on Nexus:**
```bash
username: admin
password: get the password by ssh to your server and get the initial password through => `docker exec -it nexus cat /nexus-data/admin.password`
```
8. **Run the playbook to set up SonarQube:**
```bash
  ansible-playbook -i inventory.yml playbooks/sonarqube_setup.yml
```
9. **Open SonarQube:**
```bash
http://<your_nexus_server_IP>:9000
```
10. **login on SonarQube:**
```bash
username: admin
password: admin
```
11. **Run the playbook to set up K8s:**
```bash
  ansible-playbook -i inventory.yml playbooks/k8s_setup.yml
```
12. ** Get the cluster IP:**
```bash
sudo su
cd /root/.kube
cat config | grep "server"
```
or get it from the **AWS** GUI it's the same as the **private IP** for the master node or you can print it using **Terraform** output.

13. **Update the Jenkins file with it:**
```bash
code complete_CICD_project/Jenkinsfile
```
update the following steps by replacing the IP written in then with the IP that you got from the previous step:
* Deploy To Kubernetes.
* update the Deployment
* Verify the Deployment
### How to run and manage the CI/CD pipeline
### How to access monitoring dashboards

14. **Make sure that the worker nodes joined the cluster:**
```bash
sudo kubectl get nodes # Run it on the K8s master node
```
15. **Run the playbook to set up Jenkins:**
```bash
  ansible-playbook -i inventory.yml playbooks/jenkins_setup.yml
```
16. **Open Jenkins:**
```bash
http://<your_nexus_server_IP>:8080
```
17. **Unlock Jenkins & create the admin user with the related password.**
18. **Creating a Jenkins API Token:**
  * Log in to your Jenkins instance.
  * Click on your username in the top right corner of the dashboard.
  * Select **Configure** from the dropdown menu.
  * Scroll down to the **API Token** section.
  * Click on **Add new Token** or **Generate** to create a new API token.
  * Copy the generated token and store it securely.
19. **Creating a SonarQube Token:**
  * Log in to your SonarQube instance.
  * Navigate to **Administration** in the main menu.
  * Select **Security** from the submenu.
  * Click on **Users**.
  * Find your user account and click on it.
  * In the **Tokens** section, click on **Generate** to create a new token.
  * Copy the generated token and store it securely.
20 **Prepare your Nexus Username.**
21. **Prepare your Nexus Password.**
22. **Creating a Docker Hub Personal Access Token:**
  * Log in to your Docker Hub account.
  * Click on your username in the top right corner.
  * Select **Account Settings** from the dropdown menu.
  * Navigate to the **Security** tab.
  * Under the **Personal access tokens** section, click on **Create Access Token**.
  * Enter a descriptive name for your token and select the **Read & Write** scope.
  * Click **Generate** to create the token.
  * Copy the generated token and store it securely, as it will not be displayed again.
23. **Creating a SonarQube Webhook:**
  * Log in to your SonarQube instance.
  * Navigate to **Administration** in the main menu.
  * Select **Configuration** from the submenu.
  * Click on **Webhooks**.
  * Click on the **Create** button.
  * Enter a name for your webhook (e.g., "Jenkins Webhook").
  * In the **URL** field, enter the following URL: `http://<Jenkins-IP>:8080/sonarqube-webhook/`
  * Click **Save** to create the webhook.
24. **Get Maven Releases and Snapshots URLs from Nexus.**
25. **Update the pom.xml file:**
```
code complete_CICD_project/boardgame/pom.xml
```
```
 <distributionManagement>
        <repository>
            <id>maven-releases</id>
            <url>http://<your_nexus_server_IP>:8081/repository/maven-releases/</url>
        </repository>
        <snapshotRepository>
            <id>maven-snapshots</id>
            <url>http://<your_nexus_server_IP>:8081/repository/maven-snapshots/</url>
        </snapshotRepository>
    </distributionManagement>
```
26. **Push the change to GitHub.**
27. **Run the playbook to install Jenkins plugins:**
```bash
  ansible-playbook -i inventory.yml playbooks/jenkins_install_plugins.yml
```
28. **Apply Jenkins Configuration as Code**
  * Log in to your Jenkins instance.
  * Navigate to **Manage Jenkins** from the left sidebar.
  * Click on **Configuration as Code**.
  * In the **Path or URL** field, enter the following path:
  ```/var/lib/jenkins/casc_configs```
  * Click on **Apply new configuration** to save and apply the changes.
29. **Open Jenkins:**
```bash
http://<your_nexus_server_IP>:8080
```
30. **Check that all the plugins were installed from the UI.**
31. **Check that all the tools were installed in the tools section.**
32. **Check that the managed configuration file is added successfully.**
33. **Check that the credentials were added.**
34. **Check on the system (sonar)**
35. **Copy the pipeline from the repository and update the created pipeline with it:**
```
complete_CICD_project/Jenkinsfile
```
36. **Run the playbook to set up Monitoring:**
```bash
  ansible-playbook -i inventory.yml playbooks/monitoring_setup.yml
```
37. **Update the `promethues.yml` file with your IPs.**
38. **Add prometheus as a datassource.**
39. **Create the dashboards like [here](https://github.com/AhmedWaleedAhmed/DevOpsPipelineMastery/blob/main/Complete_CICD%20_Project.pdf).**
40. **Run the pipeline.**
---

