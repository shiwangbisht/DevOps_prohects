provider "aws" {
  region = "us-east-1" # Change region if needed
}

# Security Group to allow inbound traffic on Jenkins port (8081)
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow Jenkins access on port 8081"

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open to all (restrict in production)
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open to all (restrict in production)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance to install Jenkins
resource "aws_instance" "jenkins_server" {
  ami                         = "ami-01f5a0b78d6089704" # Amazon Linux 2 AMI (verify latest)
  instance_type               = "t2.medium"             # Minimum recommended for Jenkins
  key_name                    = "jenkins-key"           # Replace with your key-pair name
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "Jenkins-Server"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras enable corretto8
              sudo yum install -y java-1.8.0-amazon-corretto
              sudo yum install -y wget

              # Install Jenkins
              sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
              sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
              sudo yum install -y jenkins

              # Change Jenkins port to 8081
              sudo sed -i 's/HTTP_PORT=8080/HTTP_PORT=8081/' /etc/sysconfig/jenkins

              # Start Jenkins on port 8081
              sudo systemctl enable jenkins
              sudo systemctl start jenkins
            EOF

  provisioner "local-exec" {
    command = "echo Jenkins server public IP: ${self.public_ip}"
  }
}

# Output Jenkins URL
output "jenkins_url" {
  value       = "http://${aws_instance.jenkins_server.public_ip}:8081"
  description = "Access your Jenkins server using this URL"
}

output "jenkins_pubIP" {
  value       = aws_instance.jenkins_server.public_ip
  description = "your public IP"
}