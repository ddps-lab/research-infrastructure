resource "aws_security_group" "cluster_sg" {
  ingress = [{
    cidr_blocks      = [ var.vpc.cidr_block ]
    description      = ""
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  },
  {
    cidr_blocks      = [ "0.0.0.0/0" ]
    description      = ""
    from_port        = 1024
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 65535
  }]
  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
  vpc_id = var.vpc.id

  tags = {
    "Name" = "${var.cluster_prefix}-cluster-sg"
  }
}

module "master_node" {
  source                = "./master_node"
  cluster_prefix        = var.cluster_prefix
  master_node_number    = var.master_node_number
  cluster_sg_id         = aws_security_group.cluster_sg.id
  vpc                   = var.vpc
  private_subnet_ids     = var.private_subnet_ids
  instance_type         = var.instance_type
  ubuntu_ami            = var.ubuntu_ami
  ec2_instance_profile  = var.ec2_instance_profile
  key_name              = var.key_name
  private_subnet         = data.aws_subnet.private_subnet
}

module "worker_node" {
  source                = "./worker_node"
  cluster_prefix        = var.cluster_prefix
  worker_node_number    = var.worker_node_number
  cluster_sg_id         = aws_security_group.cluster_sg.id
  vpc                   = var.vpc
  private_subnet_ids    = var.private_subnet_ids
  instance_type         = var.instance_type
  ubuntu_ami            = var.ubuntu_ami
  ec2_instance_profile  = var.ec2_instance_profile
  key_name              = var.key_name
  private_subnet        = data.aws_subnet.private_subnet
}
