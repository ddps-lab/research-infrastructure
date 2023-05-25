output "subnets" {
  value = aws_subnet.ddps.*.id
}
output "clusterName" {
  value = var.cluster_name
}