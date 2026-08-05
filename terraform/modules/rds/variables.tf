variable "name" {
  description = "Prefixo para nomes de recursos"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}

variable "private_subnets" {
  description = "Subnets privadas para a instância RDS"
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "Security groups autorizados a ligar à porta 5432 (nodes do EKS)"
  type        = list(string)
}

variable "instance_class" {
  description = "Classe da instância RDS"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_name" {
  description = "Nome da base de dados"
  type        = string
  default     = "challenge"
}

variable "db_username" {
  description = "Utilizador master da base de dados"
  type        = string
  default     = "challenge"
}

variable "tags" {
  description = "Tags extra para os recursos"
  type        = map(string)
  default     = {}
}
