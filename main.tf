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

# Configure the Security Group (Instance-level firewall)
resource "aws_security_group" "web_sg" {
  name        = "zero-touch-sg"
  description = "Allow SSH and Flask application traffic"

  # Allow SSH for deployment
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  # Allow web traffic to our Flask app
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic (needed to download Docker)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Provision the EC2 Instance
resource "aws_instance" "app_server" {
  ami           = "ami-0c7217cdde317cfec" # Ubuntu 22.04 LTS in us-east-1
  instance_type = "t3.micro"              # Updated Free-tier eligible
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # Bootstrap script to install Docker, pull your code, and run it
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install docker.io git -y
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ubuntu
              
              # Clone your public repository
              git clone https://github.com/Talotoluwa/Zero-touch-pipeline.git /home/ubuntu/app
              cd /home/ubuntu/app
              
              # Build and run the Docker container
              sudo docker build -t zero-touch-app .
              sudo docker run -d -p 5000:5000 zero-touch-app
              EOF

  tags = {
    Name = "ZeroTouchPipelineServer"
  }
}