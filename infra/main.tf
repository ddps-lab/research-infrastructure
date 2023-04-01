provider "aws" {
  #Seoul region
  region  = var.region
  profile = var.awscli_profile
}

module "vpc" {
  source               = "./vpc"
  vpc_name             = "${var.main_suffix}-k8s-vpc"
  vpc_cidr             = var.vpc_cidr
  current_region       = data.aws_region.current_region.id
  region_azs           = data.aws_availability_zones.region_azs.names
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  ubuntu_ami           = data.aws_ami.ubuntu_ami
  key_name             = var.key_name
  ec2_instance_profile = aws_iam_instance_profile.nat-ec2role-instance-profile.name
  cluster_prefix        = "${var.main_suffix}-k8s"
}

module "k8s" {
  source                = "./k8s"
  cluster_prefix        = "${var.main_suffix}-k8s"
  vpc                   = module.vpc.vpc
  public_subnet_ids     = module.vpc.public_subnet_ids
  private_subnet_ids    = module.vpc.private_subnet_ids
  master_node_number    = var.master_node_number
  worker_node_number    = var.worker_node_number
  instance_type         = var.instance_type
  ubuntu_ami            = data.aws_ami.ubuntu_ami
  key_name              = var.key_name
  ec2_instance_profile  = aws_iam_instance_profile.k8s-cluster-ec2role-instance-profile.name
  depends_on = [
    module.vpc
  ]
}
