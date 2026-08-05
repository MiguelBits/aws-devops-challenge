region          = "eu-south-2"
name            = "desafio"
cluster_name    = "desafio-eks"
cluster_version = "1.33"

# Ajustar ao teu repositório antes do apply:
github_org  = "MiguelBits"
github_repo = "aws-devops-challenge"

# Substituir pelo teu email; vais receber um pedido de confirmação do SNS:
alarm_email = "substituir@example.com"

clicks_threshold   = 10
log_retention_days = 14
