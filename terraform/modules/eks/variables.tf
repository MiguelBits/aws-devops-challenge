variable "cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
}

variable "cluster_version" {
  description = "Versão do Kubernetes no EKS"
  type        = string
  default     = "1.33"
}

variable "vpc_id" {
  description = "ID da VPC onde o cluster é criado"
  type        = string
}

variable "private_subnets" {
  description = "Subnets privadas para o plano de controlo e os nodes"
  type        = list(string)
}

variable "endpoint_public_access_cidrs" {
  description = "CIDRs com acesso ao endpoint público da API do cluster (restringir ao teu IP em produção)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Tags extra para os recursos"
  type        = map(string)
  default     = {}
}
