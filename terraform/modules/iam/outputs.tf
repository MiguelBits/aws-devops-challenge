output "github_actions_role_arn" {
  description = "ARN do role para o GitHub Actions (configurar como secret AWS_ROLE_ARN no repositório)"
  value       = aws_iam_role.github_actions.arn
}
