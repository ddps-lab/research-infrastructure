data "aws_region" "current_region" {}

data "aws_availability_zones" "region_azs" {
  state = "available"
  filter {
    name = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_ami" "ubuntu_ami" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}