provider "aws" {
  #Seoul region
  region  = "ap-northeast-2"
  profile = "ddpslab"
}

module "vpc" {
  source               = "./vpc"
  vpc_name             = var.vpc_name
  vpc_cidr             = var.vpc_cidr
  current_region       = data.aws_region.current_region.id
  region_azs           = data.aws_availability_zones.region_azs.names
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  ubuntu_ami           = data.aws_ami.ubuntu_ami
  key_name             = var.key_name
  ec2_instance_profile = var.ec2_instance_profile
}

module "k8s" {
  source                = "./k8s"
  cluster_prefix        = var.cluster_prefix
  vpc                   = module.vpc.vpc
  public_subnet_ids     = module.vpc.public_subnet_ids
  private_subnet_ids    = module.vpc.private_subnet_ids
  master_node_number    = var.master_node_number
  worker_node_number    = var.worker_node_number
  instance_type         = var.instance_type
  ubuntu_ami            = data.aws_ami.ubuntu_ami
  key_name              = var.key_name
  ec2_instance_profile  = var.ec2_instance_profile
  install_k8s_user_data = var.install_k8s_user_data
  depends_on = [
    module.vpc
  ]
}
