variable "name" {
  description = "Prefixo para nomes de recursos"
  type        = string
}

variable "cluster_name" {
  description = "Nome do cluster EKS (usado nas tags das subnets para o ALB controller)"
  type        = string
}

variable "cidr" {
  description = "CIDR da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "tags" {
  description = "Tags extra para os recursos"
  type        = map(string)
  default     = {}
}
