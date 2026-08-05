variable "name" {
  description = "Prefixo para nomes de recursos"
  type        = string
}

variable "region" {
  description = "Região AWS"
  type        = string
}

variable "cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
}

variable "github_org" {
  description = "Organização ou utilizador dono do repositório GitHub"
  type        = string
}

variable "github_repo" {
  description = "Nome do repositório GitHub autorizado a assumir o role de deploy"
  type        = string
}

variable "ecr_repository_arns" {
  description = "ARNs dos repositórios ECR onde o GitHub Actions pode fazer push"
  type        = list(string)
}

variable "db_secret_arn" {
  description = "ARN do secret da base de dados que o External Secrets Operator pode ler"
  type        = string
}

variable "metrics_namespace" {
  description = "Namespace CloudWatch onde a API publica métricas"
  type        = string
  default     = "ChallengeApp"
}

variable "tags" {
  description = "Tags extra para os recursos"
  type        = map(string)
  default     = {}
}
