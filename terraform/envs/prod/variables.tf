variable "region" {
  description = "Região AWS"
  type        = string
  default     = "eu-south-2"
}

variable "name" {
  description = "Prefixo para nomes de recursos"
  type        = string
  default     = "desafio"
}

variable "cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
  default     = "desafio-eks"
}

variable "cluster_version" {
  description = "Versão do Kubernetes no EKS"
  type        = string
  default     = "1.33"
}

variable "github_org" {
  description = "Organização ou utilizador dono do repositório GitHub"
  type        = string
}

variable "github_repo" {
  description = "Nome do repositório GitHub"
  type        = string
}

variable "alarm_email" {
  description = "Email para notificações de alarmes (requer confirmação manual da subscrição SNS)"
  type        = string
}

variable "clicks_threshold" {
  description = "Cliques por minuto que disparam o alarme"
  type        = number
  default     = 10
}

variable "log_retention_days" {
  description = "Dias de retenção dos logs no CloudWatch"
  type        = number
  default     = 14
}
