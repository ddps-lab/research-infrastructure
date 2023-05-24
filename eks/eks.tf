module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.26"
  vpc_id          = aws_vpc.ddps.id
  subnet_ids      = aws_subnet.ddps[*].id
  enable_irsa     = true

  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
  }
  tags = {
    "karpenter.sh/discovery" = var.cluster_name
  }
  # eks_managed_node_group_defaults = {
  #   instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  # }

  eks_managed_node_groups = {
    karpenter = {
      instance_types = ["t4g.medium"]
      capacity_type  = "ON_DEMAND"
      ami_type       = "AL2_ARM_64"

      min_size     = 2
      max_size     = 5
      desired_size = 2

      create_iam_role = false
      iam_role_arn    = aws_iam_role.eksNodeRole.arn
      manage_aws_auth = false
    }
  }
}

resource "null_resource" "kubectl" {
  depends_on = [module.eks.eks_managed_node_groups]
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${var.cluster_name} --profile default"
  }
}
