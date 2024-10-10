all:
  children:
    k8s_cluster:
      children:
        k8s_master:
          hosts:
            master:
              ansible_host: ${master_ip}
        k8s_workers:
          hosts:
            worker1:
              ansible_host: ${worker1_ip}
            worker2:
              ansible_host: ${worker2_ip}
    sonarqube:
      hosts:
        sonarqube:
          ansible_host: ${sonarqube_ip}
    nexus:
      hosts:
        nexus:
          ansible_host: ${nexus_ip}
    jenkins:
      hosts:
        jenkins:
          ansible_host: ${jenkins_ip}
    monitoring:
      hosts:
        monitoring:
          ansible_host: ${monitoring_ip}
