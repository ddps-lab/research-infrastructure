module "iam_assumable_role_karpenter" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "4.7.0"
  create_role                   = true
  role_name                     = "karpenter-controller-${var.cluster_name}"
  provider_url                  = module.eks.cluster_oidc_issuer_url
  oidc_fully_qualified_subjects = ["system:serviceaccount:karpenter:karpenter"]
}
resource "helm_release" "karpenter" {
  depends_on       = [module.eks.eks_managed_node_groups]
  namespace        = "karpenter"
  create_namespace = true
  name             = "karpenter"
  repository       = "https://charts.karpenter.sh"
  chart            = "karpenter"
  version          = "v0.6.0"
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.iam_assumable_role_karpenter.iam_role_arn
  }
  set {
    name  = "controller.clusterName"
    value = var.cluster_name
  }
  set {
    name  = "controller.clusterEndpoint"
    value = module.eks.cluster_endpoint
  }
  set {
    name  = "aws.defaultInstanceProfile"
    value = aws_iam_role.ddps-node.name
  }
}
