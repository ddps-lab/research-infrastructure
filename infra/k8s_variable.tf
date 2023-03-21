variable "cluster_prefix" {
  type = string
  default = "ddps-k8s"
}

variable "master_node_number" {
  type = number
  default = 1
}

variable "worker_node_number" {
  type = number
  default = 1
}