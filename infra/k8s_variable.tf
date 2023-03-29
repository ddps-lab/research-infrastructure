variable "instance_type" {
  type = string
  default = "t4g.medium"
}

variable "key_name" {
  type = string
  description = "EC2 Instance Key Name"
  default = "<>"
}

variable "master_node_number" {
  type = number
  default = 1
}

variable "worker_node_number" {
  type = number
  default = 1
}