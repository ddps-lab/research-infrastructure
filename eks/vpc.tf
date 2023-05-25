resource "aws_vpc" "ddps" {
  cidr_block = "10.0.0.0/16"

  tags = tomap({
    "Name"                                      = "eks-ddps",
    "kubernetes.io/cluster/${var.cluster_name}" = "shared",
    "karpenter.sh/discovery"                    = var.cluster_name
  })
}

resource "aws_subnet" "ddps" {
  count = 2

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.ddps.id
  tags = tomap({
    "Name"                                      = "eks-ddps",
    "kubernetes.io/cluster/${var.cluster_name}" = "shared",
    "karpenter.sh/discovery"                    = var.cluster_name
  })
}

resource "aws_internet_gateway" "ddps" {
  vpc_id = aws_vpc.ddps.id

  tags = {
    Name                     = "eks-ddps",
    "karpenter.sh/discovery" = var.cluster_name
  }
}

resource "aws_route_table" "ddps" {
  vpc_id = aws_vpc.ddps.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ddps.id
  }
}

resource "aws_route_table_association" "ddps" {
  count = 2

  subnet_id      = aws_subnet.ddps.*.id[count.index]
  route_table_id = aws_route_table.ddps.id
}
