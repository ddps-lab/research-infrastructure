output "subnets" {
  value = aws_subnet.ddps.*.id
}
output "clsuterName" {
  value = var.cluster_name
}
