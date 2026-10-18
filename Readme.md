# Zero-Touch Docker Pipeline

An automated CI/CD deployment pipeline that provisions AWS infrastructure and deploys a containerized web application without manual intervention.

## Architecture Overview
This project demonstrates modern Infrastructure as Code (IaC) and deployment automation principles. Every code push automatically triggers a GitHub Actions workflow that securely authenticates with AWS, provisions compute resources via Terraform, and bootstraps a Dockerized Python application.

## Technology Stack
| Component | Technology | Purpose |
| :--- | :--- | :--- |
| **Application** | Python / Flask | Lightweight, stateless web service |
| **Containerization** | Docker | Environment consistency and application packaging |
| **Infrastructure** | Terraform / HCL | Immutable infrastructure provisioning |
| **CI/CD** | GitHub Actions | Automated deployment orchestration |
| **Cloud Provider** | AWS (EC2, SG, IAM) | Compute and network security |

## Core Features
* **Infrastructure as Code:** Defines AWS EC2 instances and Security Groups using Terraform.
* **Automated Bootstrapping:** Utilizes EC2 `user_data` scripts to install dependencies, pull the repository, and build/run the container seamlessly on instance startup.
* **Network Security:** Implements strict Security Group ingress rules, routing standard Port 80 web traffic into the container's isolated Port 5000 to safely bypass strict corporate firewalls.
* **Stateless Deployment:** Ensures every push to the `main` branch builds a completely fresh, identical environment.

## Deployment Flow
1. Developer pushes code to the `main` branch.
2. GitHub Actions injects encrypted AWS IAM credentials via repository secrets.
3. Terraform initializes and applies the infrastructure blueprint.
4. AWS provisions a `t3.micro` EC2 instance and configures the Security Group firewall.
5. The instance automatically pulls the repository, builds the Docker image, and serves the application to the public IP.

