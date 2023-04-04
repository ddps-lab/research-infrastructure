#Create Virtual Private Cloud
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

#Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    "Name" = "${var.vpc_name}-igw"
  }
}

#Create Public Subnets
resource "aws_subnet" "public_subnets" {
  vpc_id = aws_vpc.vpc.id
  count = length(var.public_subnet_cidrs)
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = var.region_azs[count.index]
  enable_resource_name_dns_a_record_on_launch = true
  map_public_ip_on_launch = true

  tags = {
    "Name" : "${var.vpc_name}-public-subnet-${substr(var.region_azs[count.index], -1, 1)}"
    "kubernetes.io/cluster/${var.cluster_prefix}" : "shared"
    "kubernetes.io/role/elb" : 1
  }
}

#Create Private Subnets
resource "aws_subnet" "private_subnets" {
  vpc_id = aws_vpc.vpc.id
  count = length(var.private_subnet_cidrs)
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = var.region_azs[count.index]
  enable_resource_name_dns_a_record_on_launch = true

  tags = {
    "Name" : "${var.vpc_name}-private-subnet-${substr(var.region_azs[count.index], -1, 1)}"
    "kubernetes.io/cluster/${var.cluster_prefix}" : "shared"
    "kubernetes.io/role/internal-elb" : 1
  }
}

#Create public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    "Name" : "${var.vpc_name}-public-route-table"
    "kubernetes.io/cluster/${var.cluster_prefix}" : "shared"
  }
}

#Create private route tables
resource "aws_route_table" "private_route_tables" {
  vpc_id = aws_vpc.vpc.id
  # count = "${length(var.region_azs)}"
  count = 1

  route {
    cidr_block = "0.0.0.0/0"
    network_interface_id = aws_instance.NAT-Instance[count.index].primary_network_interface_id
  }

  tags = {
    "Name" : "${var.vpc_name}-private-route-table-${substr(var.region_azs[count.index], -1, 1)}"
    "kubernetes.io/cluster/${var.cluster_prefix}" : "shared"
  }
}

#Route table associations
resource "aws_route_table_association" "public_subnet_route_association" {
  count = length(var.public_subnet_cidrs)
  subnet_id = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_subnet_route_associations" {
  count = length(var.private_subnet_cidrs)
  subnet_id = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_tables[count.index].id
}

# Systems Manager VPC Endpoint
# resource "aws_security_group" "ssm_vpc_endpoint_sg" {
#   ingress = [ {
#     cidr_blocks = [ var.vpc_cidr ]
#     description = ""
#     from_port = 0
#     ipv6_cidr_blocks = []
#     prefix_list_ids = []
#     protocol = "tcp"
#     security_groups = []
#     self = false
#     to_port = 443
#   } ]
#   egress = [ {
#     cidr_blocks = [ "0.0.0.0/0" ]
#     description = ""
#     from_port = 0
#     ipv6_cidr_blocks = [ ]
#     prefix_list_ids = [ ]
#     protocol = "-1"
#     security_groups = [ ]
#     self = false
#     to_port = 0
#   } ]
#   vpc_id = aws_vpc.vpc.id
# }

# resource "aws_vpc_endpoint" "ssm_vpc_endpoint" {
#   vpc_id = aws_vpc.vpc.id
#   vpc_endpoint_type = "Interface"
#   service_name = "com.amazonaws.${var.current_region}.ssm"
#   security_group_ids = [ aws_security_group.ssm_vpc_endpoint_sg.id ]
#   subnet_ids = tolist(aws_subnet.private_subnets[*].id)
# }

# resource "aws_vpc_endpoint" "ec2messages_vpc_endpoint" {
#   vpc_id = aws_vpc.vpc.id
#   vpc_endpoint_type = "Interface"
#   service_name = "com.amazonaws.${var.current_region}.ec2messages"
#   security_group_ids = [ aws_security_group.ssm_vpc_endpoint_sg.id ]
#   subnet_ids = tolist(aws_subnet.private_subnets[*].id)
# }

# resource "aws_vpc_endpoint" "ssmmessages_vpc_endpoint" {
#   vpc_id = aws_vpc.vpc.id
#   vpc_endpoint_type = "Interface"
#   service_name = "com.amazonaws.${var.current_region}.ssmmessages"
#   security_group_ids = [ aws_security_group.ssm_vpc_endpoint_sg.id ]
#   subnet_ids = tolist(aws_subnet.private_subnets[*].id)
# }