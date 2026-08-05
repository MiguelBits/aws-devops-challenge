variable "name" {
  description = "Prefixo para nomes de recursos"
  type        = string
}

variable "cluster_name" {
  description = "Nome do cluster EKS (define os nomes dos log groups)"
  type        = string
}

variable "alarm_email" {
  description = "Email que recebe as notificações de alarmes (requer confirmação manual da subscrição)"
  type        = string
}

variable "clicks_threshold" {
  description = "Número de cliques por minuto que dispara o alarme"
  type        = number
  default     = 10
}

variable "metrics_namespace" {
  description = "Namespace CloudWatch da métrica de cliques"
  type        = string
  default     = "ChallengeApp"
}

variable "log_retention_days" {
  description = "Dias de retenção dos logs no CloudWatch"
  type        = number
  default     = 14
}

variable "tags" {
  description = "Tags extra para os recursos"
  type        = map(string)
  default     = {}
}
