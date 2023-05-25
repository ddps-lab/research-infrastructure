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
    helm_release.cert_manager,
    module.karpenter_irsa_role
  ]
  name       = "ingress"
  chart      = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  version    = "1.4.6"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }
}
