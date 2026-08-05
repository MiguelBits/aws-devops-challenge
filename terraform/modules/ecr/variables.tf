variable "name" {
  description = "Prefixo para nomes de recursos"
  type        = string
}

variable "repositories" {
  description = "Nomes dos repositórios ECR a criar"
  type        = list(string)
  default     = ["frontend", "api"]
}

variable "tags" {
  description = "Tags extra para os recursos"
  type        = map(string)
  default     = {}
}
