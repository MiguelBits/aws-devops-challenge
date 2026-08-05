module "vpc" {
  source = "../../modules/vpc"

  name         = var.name
  cluster_name = var.cluster_name
}

module "eks" {
  source = "../../modules/eks"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
}

module "ecr" {
  source = "../../modules/ecr"

  name         = var.name
  repositories = ["frontend", "api"]
}

module "rds" {
  source = "../../modules/rds"

  name                       = var.name
  vpc_id                     = module.vpc.vpc_id
  private_subnets            = module.vpc.private_subnets
  allowed_security_group_ids = [module.eks.node_security_group_id]
}

module "iam" {
  source = "../../modules/iam"

  name                = var.name
  region              = var.region
  cluster_name        = var.cluster_name
  github_org          = var.github_org
  github_repo         = var.github_repo
  ecr_repository_arns = values(module.ecr.repository_arns)
  db_secret_arn       = module.rds.secret_arn

  # As associações de Pod Identity exigem que o cluster já exista.
  depends_on = [module.eks]
}

module "observability" {
  source = "../../modules/observability"

  name               = var.name
  cluster_name       = var.cluster_name
  alarm_email        = var.alarm_email
  clicks_threshold   = var.clicks_threshold
  log_retention_days = var.log_retention_days
}

# O role do GitHub Actions entra no cluster no grupo "deployers", que os
# manifests em deploy/k8s limitam ao namespace app via RoleBinding.
resource "aws_eks_access_entry" "github_actions" {
  cluster_name      = module.eks.cluster_name
  principal_arn     = module.iam.github_actions_role_arn
  kubernetes_groups = ["deployers"]
  type              = "STANDARD"
}
