# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# --- VPC and Subnets ---
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0" # Use a stable version

  name = "${var.project_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Environment = "production"
    Project     = var.project_name
  }
}

# --- ECR Repository for Docker Images ---
resource "aws_ecr_repository" "app_repo" {
  name                 = "${var.project_name}-app"
  image_tag_mutability = "MUTABLE" # Or IMMUTABLE
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project = var.project_name
  }
}

# --- EKS Cluster ---
module "eks_cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.16.0" # Use a stable version

  cluster_name    = "${var.project_name}-cluster"
  cluster_version = var.cluster_version

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets # EKS control plane in private subnets

  # EKS Cluster Authentication
  # Define IAM roles and attach policies for EKS.
  # For GitHub Actions, you might use OIDC provider for fine-grained access.
  # For simplicity here, ensure the GitHub Actions user has permissions.

  # EKS Managed Node Groups
  eks_managed_node_groups = {
    general = {
      instance_types = [var.instance_type]
      desired_size   = var.desired_size
      max_size       = var.max_size
      min_size       = var.min_size
      vpc_security_group_ids = [module.vpc.default_security_group_id]
      disk_size      = 20
      ami_type       = "AL2_x86_64" # Amazon Linux 2
      tags = {
        Name = "${var.project_name}-worker-node"
      }
    }
  }

  tags = {
    Environment = "production"
    Project     = var.project_name
  }
}

# --- RDS PostgreSQL Database ---
module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.5.0" # Use a stable version

  identifier = "${var.project_name}-db"

  engine            = "postgres"
  engine_version    = "13.9" # Match PostgreSQL version used in app
  instance_class    = var.db_instance_type
  allocated_storage = var.db_allocated_storage

  db_name  = "urlshortenerdb" # Same as in app/app.py
  username = var.db_username
  password = var.db_password # Use sensitive variable

  port = 5432

  # Enable multi-AZ for high availability
  multi_az = true
  # Set desired backup retention days
  backup_retention_period = 7
  # Enable deletion protection for production
  deletion_protection = true

  # Attach to VPC and create subnet group
  vpc_security_group_ids = [module.rds.db_security_group_id] # Default SG from RDS module
  subnet_ids             = module.vpc.private_subnets

  tags = {
    Environment = "production"
    Project     = var.project_name
  }
}

# --- RDS Security Group Rule: Allow EKS Nodes to connect to RDS ---
resource "aws_security_group_rule" "eks_to_rds" {
  description = "Allow EKS worker nodes to connect to RDS"
  type        = "ingress"
  from_port   = 5432
  to_port     = 5432
  protocol    = "tcp"
  security_group_id = module.rds.db_security_group_id # The security group of the RDS instance

  # Source is the security group of the EKS worker nodes
  source_security_group_id = module.eks_cluster.node_security_group_id
}

# --- Kubernetes Secret for Database Credentials (Manual creation or via external secret manager) ---
# This is a conceptual resource as Terraform does not directly manage K8s Secrets securely.
# In a real setup, you'd use AWS Secrets Manager with External Secrets Operator or similar.
# For demo, you'd create this secret manually *after* RDS is provisioned.
/*
resource "kubernetes_secret" "db_secrets" {
  metadata {
    name = "url-shortener-db-secrets"
  }
  data = {
    dbname          = "urlshortenerdb"
    dbuser          = var.db_username
    dbpassword      = var.db_password
    dbhost          = module.rds.db_instance_address
    dbport          = "5432"
    flask_secret_key = var.flask_secret_key # Define this as a variable or generate
  }
  type = "Opaque"
}
*/
