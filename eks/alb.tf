resource "null_resource" "iam-oidc-provider" {
  provisioner "local-exec" {
    command = "eksctl utils associate-iam-oidc-provider --region ${var.region} --cluster ${var.cluster_name} --approve"
  }
}
resource "helm_release" "cert_manager" {
  chart      = "cert-manager"
  repository = "https://charts.jetstack.io"
  name       = "cert-manager"

  create_namespace = "cert_manager"
  namespace        = "cert_manager"

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
