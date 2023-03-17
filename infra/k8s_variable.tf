variable "cluster_prefix" {
  type = string
  default = "mhsong-k8s"
}

variable "master_node_number" {
  type = number
  default = 1
}

variable "worker_node_number" {
  type = number
  default = 1
}

variable "install_k8s_user_data" {
  type = string
  default = <<EOF
  # #!/bin/bash
  # sudo su
  # apt update -y
  # apt install -y apt-transport-https ca-certificates curl
  # curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
  # echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
  # apt update -y
  # apt install -y kubelet kubeadm kubectl containerd
  EOF
}