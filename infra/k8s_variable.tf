variable "cluster_prefix" {
  type = string
  default = "${var.main_suffix}-k8s"
}

variable "master_node_number" {
  type = number
  default = 1
}

variable "worker_node_number" {
  type = number
  default = 1
}