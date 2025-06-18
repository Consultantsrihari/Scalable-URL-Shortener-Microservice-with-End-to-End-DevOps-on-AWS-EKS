variable "aws_region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "us-east-1" # Or your preferred region
}

variable "project_name" {
  description = "A unique name for the project to prefix resources"
  type        = string
  default     = "url-shortener"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.28" # Choose a supported EKS version
}

variable "instance_type" {
  description = "EC2 instance type for EKS worker nodes"
  type        = string
  default     = "t3.medium" # or t3.small for cheaper dev
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 3
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "db_instance_type" {
  description = "RDS DB instance type"
  type        = string
  default     = "db.t3.micro" # Or db.t3.small for dev/test
}

variable "db_allocated_storage" {
  description = "Allocated storage for RDS DB in GB"
  type        = number
  default     = 20
}

variable "db_username" {
  description = "Username for the RDS PostgreSQL database"
  type        = string
  default     = "urladmin"
}

variable "db_password" {
  description = "Password for the RDS PostgreSQL database"
  type        = string
  sensitive   = true # Mark as sensitive
}
