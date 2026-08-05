module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  cluster_endpoint_public_access       = true
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access_cidrs = var.endpoint_public_access_cidrs

  authentication_mode                       = "API_AND_CONFIG_MAP"
  enable_cluster_creator_admin_permissions  = true
  cluster_enabled_log_types                 = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  cluster_addons = {
    coredns                         = {}
    kube-proxy                      = {}
    vpc-cni                         = {}
    eks-pod-identity-agent          = {}
    amazon-cloudwatch-observability = {}
  }

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.medium"]
      min_size       = 2
      max_size       = 3
      desired_size   = 2
    }
  }

  tags = var.tags
}
