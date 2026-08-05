terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
  }

  # Em produção o state deve viver num backend remoto com locking, por exemplo:
  #
  # backend "s3" {
  #   bucket         = "desafio-terraform-state"
  #   key            = "prod/terraform.tfstate"
  #   region         = "eu-south-2"
  #   dynamodb_table = "desafio-terraform-locks"
  #   encrypt        = true
  # }
  #
  # O bucket e a tabela DynamoDB criam-se uma única vez à mão (ou num módulo
  # de bootstrap separado) antes do primeiro apply.
}
