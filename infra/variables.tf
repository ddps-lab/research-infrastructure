variable "main_suffix" {
  type = string
  default = "ddps"
}

variable "instance_type" {
  type = string
  default = "t4g.medium"
}
variable "key_name" {
  type = string
  description = "EC2 Instance Key Name"
  default = "mhsong-seoul-key"
}

variable "region" {
  type = string
  default = "ap-northeast-2"
}

variable "awscli_profile" {
  type = string
  default = "ddpslab"
}