resource "helm_release" "karpenter" {
  depends_on = [
    module.eks.eks_managed_node_groups,
    helm_release.ingress
  ]
  namespace        = "karpenter"
  create_namespace = true
  name             = "karpenter"
  repository       = "oci://public.ecr.aws/karpenter"
  chart            = "karpenter"
  version          = "v0.27.3"

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.karpenter_irsa_role.iam_role_arn
  }
  set {
    name  = "settings.aws.clusterName"
    value = var.cluster_name
  }
  set {
    name  = "settings.aws.clusterEndpoint"
    value = module.eks.cluster_endpoint
  }
  set {
    name  = "settings.aws.defaultInstanceProfile"
    value = aws_iam_instance_profile.KarpenterNodeInstanceProfile.name
  }
}
