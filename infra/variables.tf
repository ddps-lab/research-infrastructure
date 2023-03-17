variable "instance_type" {
  type = string
  default = "t4g.medium"
}
variable "key_name" {
  type = string
  description = "EC2 Instance Key Name"
  default = "mhsong-seoul-key"
}

variable "ec2_instance_profile" {
  type = string
  default = "ec2ssmrole-mhsong"
}