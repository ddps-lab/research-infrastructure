variable "main_suffix" {
  type = string
  default = "<>"
}

variable "instance_type" {
  type = string
  default = "t4g.medium"
}
variable "key_name" {
  type = string
  description = "EC2 Instance Key Name"
  default = "<>"
}

variable "region" {
  type = string
  default = "<>"
}

variable "awscli_profile" {
  type = string
  default = "<>"
}