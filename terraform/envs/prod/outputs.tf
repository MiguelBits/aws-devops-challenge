output "region" {
  value = var.region
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "ecr_repository_urls" {
  value = module.ecr.repository_urls
}

output "github_actions_role_arn" {
  description = "Guardar como secret AWS_ROLE_ARN no repositório GitHub"
  value       = module.iam.github_actions_role_arn
}

output "db_secret_arn" {
  value = module.rds.secret_arn
}

output "sns_topic_arn" {
  value = module.observability.sns_topic_arn
}

output "acm_certificate_arn" {
  description = "ARN do certificado do ALB (configurar como variable ACM_CERTIFICATE_ARN no GitHub)"
  value       = aws_acm_certificate.alb.arn
}

output "configure_kubectl" {
  value = "aws eks update-kubeconfig --name ${var.cluster_name} --region ${var.region}"
}
