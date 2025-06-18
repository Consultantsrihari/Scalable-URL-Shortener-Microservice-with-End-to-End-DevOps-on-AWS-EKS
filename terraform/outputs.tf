output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks_cluster.cluster_id
}

output "eks_kubeconfig" {
  description = "Kubeconfig for the EKS cluster"
  value       = module.eks_cluster.kubeconfig
  sensitive   = true
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.app_repo.repository_url
}

output "rds_endpoint" {
  description = "The endpoint of the RDS database"
  value       = module.rds.db_instance_address
}

output "rds_db_name" {
  description = "The name of the RDS database"
  value       = module.rds.db_instance_name
}

output "rds_db_username" {
  description = "The username for the RDS database"
  value       = module.rds.db_instance_username
}
