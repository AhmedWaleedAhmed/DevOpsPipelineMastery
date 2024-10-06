# terraform apply
# terraform destroy

provider "aws" {
  region = "eu-central-1"
}

resource "aws_vpc" "waleed_vpc" {
  cidr_block = "10.10.10.0/24"
  
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name = "waleed-vpc"
  }
}

resource "aws_subnet" "waleed_subnet" {
  vpc_id                  = aws_vpc.waleed_vpc.id
  cidr_block              = "10.10.10.0/25"  # Subnet CIDR must be a subset of VPC CIDR
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "waleed-subnet-public1"
  }
}

resource "aws_internet_gateway" "waleed_igw" {
  vpc_id = aws_vpc.waleed_vpc.id

  tags = {
    Name = "waleed-igw"
  }
}

resource "aws_route_table" "waleed_route_table" {
  vpc_id = aws_vpc.waleed_vpc.id

  route {
    cidr_block                = "0.0.0.0/0"
    gateway_id                = aws_internet_gateway.waleed_igw.id
  }

  tags = {
    Name = "waleed-route-table"
  }
}

resource "aws_route_table_association" "waleed_route_table_assoc" {
  subnet_id      = aws_subnet.waleed_subnet.id
  route_table_id = aws_route_table.waleed_route_table.id
}

resource "aws_security_group" "waleed_security_group" {
  vpc_id = aws_vpc.waleed_vpc.id

  name        = "waleed-security-group"
  description = "Default security group for waleed-vpc"

  ingress {
    from_port   = 3000
    to_port     = 10000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 25
    to_port     = 25
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 465
    to_port     = 465
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "waleed-security-group"
  }
}

resource "aws_instance" "jenkins" {
  ami           = "ami-0745b7d4092315796"
  instance_type = "t2.large"
  key_name      = "ahmedwaleed"
  subnet_id     = aws_subnet.waleed_subnet.id
  vpc_security_group_ids = [aws_security_group.waleed_security_group.id]
	root_block_device {
		delete_on_termination = true
		encrypted             = false
		kms_key_id            = null
		tags                  = {}
		tags_all              = {}
		throughput            = 0
		volume_size           = 30
		volume_type           = "gp2"
	}
  tags = {
    Name = "waleed-jenkins"
  }
  user_data = <<-EOF
    #!/bin/bash
    sudo cp /home/ubuntu/.ssh/authorized_keys /root/.ssh/authorized_keys
    deluser --remove-home ubuntu
    EOF
}

resource "aws_instance" "nexus" {
  ami           = "ami-0745b7d4092315796"
  instance_type = "t2.medium"
  key_name      = "ahmedwaleed"
  subnet_id     = aws_subnet.waleed_subnet.id
  vpc_security_group_ids = [aws_security_group.waleed_security_group.id]
	root_block_device {
		delete_on_termination = true
		encrypted             = false
		kms_key_id            = null
		tags                  = {}
		tags_all              = {}
		throughput            = 0
		volume_size           = 25
		volume_type           = "gp2"
	}
  tags = {
    Name = "waleed-nexus"
  }
  user_data = <<-EOF
    #!/bin/bash
    sudo cp /home/ubuntu/.ssh/authorized_keys /root/.ssh/authorized_keys
    deluser --remove-home ubuntu
    EOF
}

resource "aws_instance" "sonarQube" {
  ami           = "ami-0745b7d4092315796"
  instance_type = "t2.medium"
  key_name      = "ahmedwaleed"
  subnet_id     = aws_subnet.waleed_subnet.id
  vpc_security_group_ids = [aws_security_group.waleed_security_group.id]
	root_block_device {
		delete_on_termination = true
		encrypted             = false
		kms_key_id            = null
		tags                  = {}
		tags_all              = {}
		throughput            = 0
		volume_size           = 25
		volume_type           = "gp2"
	}
  tags = {
    Name = "waleed-sonarQube"
  }
  user_data = <<-EOF
    #!/bin/bash
    sudo cp /home/ubuntu/.ssh/authorized_keys /root/.ssh/authorized_keys
    deluser --remove-home ubuntu
    EOF
}

resource "aws_instance" "k8s-master" {
  ami           = "ami-0745b7d4092315796"
  instance_type = "t2.medium"
  key_name      = "ahmedwaleed"
  subnet_id     = aws_subnet.waleed_subnet.id
  vpc_security_group_ids = [aws_security_group.waleed_security_group.id]
	root_block_device {
		delete_on_termination = true
		encrypted             = false
		kms_key_id            = null
		tags                  = {}
		tags_all              = {}
		throughput            = 0
		volume_size           = 25
		volume_type           = "gp2"
	}
  tags = {
    Name = "waleed-k8s-master"
  }
  user_data = <<-EOF
    #!/bin/bash
    sudo cp /home/ubuntu/.ssh/authorized_keys /root/.ssh/authorized_keys
    deluser --remove-home ubuntu
    EOF
}

resource "aws_instance" "k8s-worker-1" {
  ami           = "ami-0745b7d4092315796"
  instance_type = "t2.medium"
  key_name      = "ahmedwaleed"
  subnet_id     = aws_subnet.waleed_subnet.id
  vpc_security_group_ids = [aws_security_group.waleed_security_group.id]
	root_block_device {
		delete_on_termination = true
		encrypted             = false
		kms_key_id            = null
		tags                  = {}
		tags_all              = {}
		throughput            = 0
		volume_size           = 25
		volume_type           = "gp2"
	}
  tags = {
    Name = "waleed-k8s-worker-1"
  }
  user_data = <<-EOF
    #!/bin/bash
    sudo cp /home/ubuntu/.ssh/authorized_keys /root/.ssh/authorized_keys
    deluser --remove-home ubuntu
    EOF
}

resource "aws_instance" "k8s-worker-2" {
  ami           = "ami-0745b7d4092315796"
  instance_type = "t2.medium"
  key_name      = "ahmedwaleed"
  subnet_id     = aws_subnet.waleed_subnet.id
  vpc_security_group_ids = [aws_security_group.waleed_security_group.id]
	root_block_device {
		delete_on_termination = true
		encrypted             = false
		kms_key_id            = null
		tags                  = {}
		tags_all              = {}
		throughput            = 0
		volume_size           = 25
		volume_type           = "gp2"
	}
  tags = {
    Name = "waleed-k8s-worker-2"
  }
  user_data = <<-EOF
    #!/bin/bash
    sudo cp /home/ubuntu/.ssh/authorized_keys /root/.ssh/authorized_keys
    deluser --remove-home ubuntu
    EOF
}

# output "vpc_id" {
#   value = aws_vpc.waleed_vpc.id
# }

# output "subnet_id" {
#   value = aws_subnet.waleed_subnet.id
# }

# output "internet_gateway_id" {
#   value = aws_internet_gateway.waleed_igw.id
# }

# output "route_table_id" {
#   value = aws_route_table.waleed_route_table.id
# }

# output "security_group_id" {
#   value = aws_security_group.waleed_security_group.id
# }

# output "instance_id" {
#   value = aws_instance.waleed_ec2.id
# }
