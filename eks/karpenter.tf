data "aws_caller_identity" "self" {}

locals {
  account_id = data.aws_caller_identity.self.account_id
}

resource "kubernetes_config_map" "aws-auth" {
  depends_on = [null_resource.kubectl]
  data = {
    "mapRoles" : <<EOT
    - groups:
      - system:bootstrappers
      - system:nodes
      rolearn: arn:aws:iam::${local.account_id}:role/eksNodeRole-${var.cluster_name}
      username: system:node:{{EC2PrivateDNSName}}
    - groups:
      - system:bootstrappers
      - system:nodes
      rolearn: arn:aws:iam::${local.account_id}:role/KarpenterInstanceNodeRole-${var.cluster_name}
      username: system:node:{{EC2PrivateDNSName}}
      EOT
  }

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
}

resource "helm_release" "karpenter" {
  depends_on       = [kubernetes_config_map.aws-auth]
  namespace        = "karpenter"
  create_namespace = true
  name             = "karpenter"
  repository       = "oci://public.ecr.aws/karpenter"
  chart            = "karpenter"
  version          = "v0.27.3"

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.KarpenterControllerRole.arn
  }
  set {
    name  = "aws.clusterName"
    value = var.cluster_name
  }
  set {
    name  = "aws.clusterEndpoint"
    value = module.eks.cluster_endpoint
  }
  set {
    name  = "aws.defaultInstanceProfile"
    value = aws_iam_role.eksNodeRole.name
  }
}


