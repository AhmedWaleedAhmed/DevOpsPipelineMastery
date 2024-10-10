# terraform apply
# terraform destroy

provider "aws" {
  region = "eu-central-1"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.10.10.0/24"
  
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name = "vpc-${var.tag_suffix}"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.10.10.0/25"  # Subnet CIDR must be a subset of VPC CIDR
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${var.tag_suffix}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw-${var.tag_suffix}"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block                = "0.0.0.0/0"
    gateway_id                = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "route-table-${var.tag_suffix}"
  }
}

resource "aws_route_table_association" "route_table_assoc" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_security_group" "security_group" {
  vpc_id      = aws_vpc.vpc.id
  name        = "security-group-${var.tag_suffix}"
  description = "Default security group for vpc-${var.tag_suffix}"

  tags = {
    Name = "security-group-${var.tag_suffix}"
  }
}

# Ingress Rules
resource "aws_security_group_rule" "allow_tcp_3000_to_10000" {
  type              = "ingress"
  from_port        = 3000
  to_port          = 10000
  protocol         = "tcp"
  security_group_id = aws_security_group.security_group.id
  cidr_blocks      = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_tcp_6443" {
  type              = "ingress"
  from_port        = 6443
  to_port          = 6443
  protocol         = "tcp"
  security_group_id = aws_security_group.security_group.id
  cidr_blocks      = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_tcp_22" {
  type              = "ingress"
  from_port        = 22
  to_port          = 22
  protocol         = "tcp"
  security_group_id = aws_security_group.security_group.id
  cidr_blocks      = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_tcp_443" {
  type              = "ingress"
  from_port        = 443
  to_port          = 443
  protocol         = "tcp"
  security_group_id = aws_security_group.security_group.id
  cidr_blocks      = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_tcp_25" {
  type              = "ingress"
  from_port        = 25
  to_port          = 25
  protocol         = "tcp"
  security_group_id = aws_security_group.security_group.id
  cidr_blocks      = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_tcp_80" {
  type              = "ingress"
  from_port        = 80
  to_port          = 80
  protocol         = "tcp"
  security_group_id = aws_security_group.security_group.id
  cidr_blocks      = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_tcp_465" {
  type              = "ingress"
  from_port        = 465
  to_port          = 465
  protocol         = "tcp"
  security_group_id = aws_security_group.security_group.id
  cidr_blocks      = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_tcp_30000_to_32767" {
  type              = "ingress"
  from_port        = 30000
  to_port          = 32767
  protocol         = "tcp"
  security_group_id = aws_security_group.security_group.id
  cidr_blocks      = ["0.0.0.0/0"]
}

# Egress Rule
resource "aws_security_group_rule" "allow_all_egress" {
  type              = "egress"
  from_port        = 0
  to_port          = 0
  protocol         = "-1"  # All traffic
  security_group_id = aws_security_group.security_group.id
  cidr_blocks      = ["0.0.0.0/0"]
}


resource "aws_instance" "jenkins" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.large_instance_type
  key_name      = var.key_name
  subnet_id     = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.security_group.id]
  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }
  tags = {
    Name = "jenkins-${var.tag_suffix}"
  }
  user_data = file("${path.module}/${var.user_data_file_path}")
}

resource "aws_instance" "nexus" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.medium_instance_type
  key_name      = var.key_name
  subnet_id     = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.security_group.id]
  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }
  tags = {
    Name = "nexus-${var.tag_suffix}"
  }
  user_data = file("${path.module}/${var.user_data_file_path}")
}

resource "aws_instance" "sonarQube" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.medium_instance_type
  key_name      = var.key_name
  subnet_id     = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.security_group.id]
  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }
  tags = {
    Name = "sonarQube-${var.tag_suffix}"
  }
  user_data = file("${path.module}/${var.user_data_file_path}")
}

resource "aws_instance" "k8s-master" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.medium_instance_type
  key_name      = var.key_name
  subnet_id     = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.security_group.id]
  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }
  tags = {
    Name = "k8s-master-${var.tag_suffix}"
  }
  user_data = file("${path.module}/${var.user_data_file_path}")
}

resource "aws_instance" "k8s-worker-1" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.medium_instance_type
  key_name      = var.key_name
  subnet_id     = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.security_group.id]
  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }
  tags = {
    Name = "k8s-worker-1-${var.tag_suffix}"
  }
  user_data = file("${path.module}/${var.user_data_file_path}")
}

resource "aws_instance" "k8s-worker-2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.medium_instance_type
  key_name      = var.key_name
  subnet_id     = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.security_group.id]
  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }
  tags = {
    Name = "k8s-worker-2-${var.tag_suffix}"
  }
  user_data = file("${path.module}/${var.user_data_file_path}")
}

resource "aws_instance" "monitoring" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.medium_instance_type
  key_name      = var.key_name
  subnet_id     = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.security_group.id]
	root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }
  tags = {
    Name = "monitoring-${var.tag_suffix}"
  }
  user_data = file("${path.module}/${var.user_data_file_path}")
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.tpl", {
    master_ip   = aws_instance.k8s-master.public_ip
    worker1_ip  = aws_instance.k8s-worker-1.public_ip
    worker2_ip  = aws_instance.k8s-worker-2.public_ip
    sonarqube_ip = aws_instance.sonarQube.public_ip
    nexus_ip    = aws_instance.nexus.public_ip
    jenkins_ip  = aws_instance.jenkins.public_ip
    monitoring_ip = aws_instance.monitoring.public_ip
  })

  filename = "${path.module}/../ansible/inventory.yml"
}


