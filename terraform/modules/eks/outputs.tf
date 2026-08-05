output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "node_security_group_id" {
  description = "Security group dos nodes (usado para autorizar acesso ao RDS)"
  value       = module.eks.node_security_group_id
}

output "cluster_certificate_authority_data" {
  description = "CA do cluster (usado pelo provider helm)"
  value       = module.eks.cluster_certificate_authority_data
}
