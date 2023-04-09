data "aws_subnet" "private_subnet" {
  count = length(var.private_subnet_ids)
  id = var.private_subnet_ids[count.index]
}