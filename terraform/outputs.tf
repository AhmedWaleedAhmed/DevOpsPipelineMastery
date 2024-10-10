
output "k8s_master_ip" {
  value = aws_instance.k8s-master.public_ip
}

output "k8s_worker_1_ip" {
  value = aws_instance.k8s-worker-1.public_ip
}

output "k8s_worker_2_ip" {
  value = aws_instance.k8s-worker-2.public_ip
}

output "sonarqube_ip" {
  value = aws_instance.sonarQube.public_ip
}

output "nexus_ip" {
  value = aws_instance.nexus.public_ip
}

output "jenkins_ip" {
  value = aws_instance.jenkins.public_ip
}

output "monitoring_ip" {
  value = aws_instance.monitoring.public_ip
}