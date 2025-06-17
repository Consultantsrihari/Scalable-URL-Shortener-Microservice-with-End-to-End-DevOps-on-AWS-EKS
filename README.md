# Scalable URL Shortener Microservice with End-to-End DevOps on AWS EKS

This project demonstrates a robust, automated, and scalable URL shortening service, showcasing modern DevOps practices.

## Overview

The application is a simple URL shortener built with Python Flask, storing short and long URL mappings in a PostgreSQL database. The core focus of this project is on the automated deployment and infrastructure management using a comprehensive DevOps toolchain.

## Key Technologies & DevOps Stack

* **Application Language & Framework:** Python 3.x, Flask
* **Database:** PostgreSQL (AWS RDS)
* **Containerization:** Docker
* **Container Registry:** Amazon Elastic Container Registry (ECR)
* **CI/CD:** GitHub Actions
* **Orchestration:** Kubernetes (AWS Elastic Kubernetes Service - EKS)
* **Infrastructure as Code (IaC):** HashiCorp Terraform
* **Cloud Provider:** Amazon Web Services (AWS)
* **Version Control:** Git, GitHub

## Project Structure
Scalable URL Shortener Microservice with End-to-End DevOps on AWS EKS
├── app/                      # Flask application and Dockerfile
│   ├── app.py                # Main Flask application logic
│   ├── requirements.txt      # Python dependencies
│   ├── Dockerfile            # Dockerfile for building the app image
│   └── templates/            # HTML templates for Flask
│       ├── index.html
│       └── 404.html
├── .github/                  # GitHub Actions CI/CD workflows
│   └── workflows/
│       └── ci-cd.yml
├── kubernetes/               # Kubernetes manifests for deployment on EKS
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
├── terraform/                # Terraform configurations for AWS infrastructure
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── docker-compose.yml        # For local development with app and PostgreSQL
└── README.md                 # This README file

## Local Development Setup

To run the application locally using Docker Compose:

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/YOUR_USERNAME/url-shortener-devops.git](https://github.com/YOUR_USERNAME/url-shortener-devops.git)
    cd url-shortener-devops
    ```
2.  **Create `.env` file (for local DB credentials):**
    Create `app/.env` with the following content. **Do NOT commit this file to Git.**
    ```
    DB_NAME=urlshortenerdb
    DB_USER=user
    DB_PASSWORD=password
    DB_HOST=db # 'db' refers to the service name in docker-compose
    DB_PORT=5432
    FLASK_SECRET_KEY=your_development_secret_key_here
    ```
3.  **Build and run with Docker Compose:**
    ```bash
    docker-compose up --build -d
    ```
4.  **Access the application:**
    Open your browser to `http://localhost:5000`

## Cloud Deployment (AWS EKS with Terraform & GitHub Actions)

### Prerequisites:

* An AWS Account
* AWS CLI configured with programmatic access keys
* Terraform installed
* `kubectl` installed
* `aws-iam-authenticator` (for EKS kubectl access)
* GitHub repository for this project

### 1. Infrastructure Provisioning with Terraform

Navigate to the `terraform/` directory:

Cd terraform

### initialize Terraform:

*terraform init
*terraform plan
*terraform apply

*You will be prompted to enter the db_password for your RDS instance.
Important: Note the ecr_repository_url, eks_cluster_name, and rds_endpoint from the Terraform outputs. These will be used in your CI/CD and Kubernetes manifests.

## 2. Configure AWS ECR and GitHub Secrets
Create GitHub Secrets: In your GitHub repository settings, go to Settings > Secrets and variables > Actions > New repository secret and add the following:


AWS_ACCESS_KEY_ID: Your AWS Access Key ID
AWS_SECRET_ACCESS_KEY: Your AWS Secret Access Key
AWS_REGION: The AWS region you deployed to (e.g., us-east-1)
EKS_CLUSTER_NAME: The name of your EKS cluster (from Terraform outputs)
ECR_REGISTRY_URL: Your ECR repository URL (from Terraform outputs, without the image name, e.g., 123456789012.dkr.ecr.us-east-1.amazonaws.com)
'''

### Kubernetes Secrets for DB Credentials:
NOTE: For production, use AWS Secrets Manager with External Secrets Operator for Kubernetes. For this demo, you can manually create a Kubernetes Secret. Replace placeholders with your actual values (RDS endpoint, database name, username, password, Flask secret key).

Bash

kubectl create secret generic url-shortener-db-secrets \
  --from-literal=dbhost=<YOUR_RDS_ENDPOINT_FROM_TERRAFORM_OUTPUTS> \
  --from-literal=dbport=5432 \
  --from-literal=dbname=urlshortenerdb \
  --from-literal=dbuser=<YOUR_DB_USERNAME> \
  --from-literal=dbpassword=<YOUR_DB_PASSWORD> \
  --from-literal=flask_secret_key=your_flask_secret_key_for_production
Replace <YOUR_DB_USERNAME> and <YOUR_DB_PASSWORD> with the values you provided to Terraform.

### 3. Update Kubernetes Ingress
Edit kubernetes/ingress.yaml to replace subnet-xxxxxxxxxxxxxxxxx,subnet-yyyyyyyyyyyyyyyyy with the actual public subnet IDs from your Terraform VPC module outputs (or find them in the AWS Console).

## 4. CI/CD with GitHub Actions
The .github/workflows/ci-cd.yml file defines the CI/CD pipeline.

It checks out code, installs dependencies, builds the Docker image, logs into ECR, pushes the image to ECR, and then deploys to EKS.
The deployment step automatically replaces the image tag in kubernetes/deployment.yaml with the newly pushed image.
Triggering the Pipeline:
Push changes to the main branch to trigger the pipeline:

Bash

git add .
git commit -m "Initial commit of DevOps setup"
git push origin main
Monitor the workflow run in your GitHub repository under the "Actions" tab.

### 5. Accessing the Deployed Application
Once the deployment job completes successfully in GitHub Actions, an AWS Application Load Balancer (ALB) will be provisioned by the Kubernetes Ingress controller.

'''
Go to the EC2 service in the AWS Console.
Navigate to "Load Balancers" under the "Load Balancing" section.
Find the ALB created by your Ingress (its name will typically start with k8s-).
Copy its DNS name and paste it into your browser. This is your live URL Shortener!
Cleanup (Important!)
To avoid unnecessary AWS costs, destroy the provisioned infrastructure when you are done.
Navigate back to the terraform/ directory:

cd terraform
terraform 
'''
This will prompt for confirmation. Type yes to proceed.
