resource "null_resource" "iam-oidc-provider" {
  depends_on = [module.eks.eks_managed_node_groups]
  provisioner "local-exec" {
    command = "eksctl utils associate-iam-oidc-provider --region ${var.aws_region} --cluster ${var.cluster_name} --approve"
  }
}
resource "helm_release" "cert_manager" {
  depends_on = [null_resource.kubectl]
  chart      = "cert-manager"
  repository = "https://charts.jetstack.io"
  name       = "cert-manager"

  create_namespace = true
  namespace        = "cert-manager"

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "helm_release" "ingress" {
  depends_on = [
    helm_release.cert_manager
  ]
  name       = "ingress"
  chart      = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  version    = "1.4.6"

  set {
    name  = "autoDiscoverAwsRegion"
    value = "true"
  }
  set {
    name  = "autoDiscoverAwsVpcID"
    value = "true"
  }
  set {
    name  = "clusterName"
    value = var.cluster_name
  }
}
