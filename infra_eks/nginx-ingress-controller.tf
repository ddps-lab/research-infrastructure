resource "helm_release" "nginx-ingress-controller" {
  depends_on = [null_resource.kubectl]
  name       = "nginx-ingress-controller"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx-ingress-controller"

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }
  # provisioner "local-exec" {
  #   when    = destroy
  #   command = "helm delete nginx-ingress-controller"
  # }
}
