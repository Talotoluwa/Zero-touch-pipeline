terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Set the AWS Region
provider "aws" {
  region = "us-east-1"
}

## Configure the Security Group (Instance-level firewall)
resource "aws_security_group" "web_sg" {
  name        = "zero-touch-sg-v3" # Renamed to avoid duplicates
  description = "Allow SSH and standard HTTP traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  # Open standard port 80 to bypass corporate firewalls
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Provision the EC2 Instance
resource "aws_instance" "app_server" {
  ami           = "ami-0c7217cdde317cfec" 
  instance_type = "t3.micro"              
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # Bootstrap script
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install docker.io git -y
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ubuntu
              
              git clone https://github.com/Talotoluwa/Zero-touch-pipeline.git /home/ubuntu/app
              cd /home/ubuntu/app
              
              sudo docker build -t zero-touch-app .
              # Route standard port 80 traffic to the container's port 5000
              sudo docker run -d -p 80:5000 zero-touch-app
              EOF

  tags = {
    Name = "ZeroTouchPipelineServer"
  }
}
