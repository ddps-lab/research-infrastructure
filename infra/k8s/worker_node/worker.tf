resource "aws_instance" "worker_node" {
  count                  = var.worker_node_number
  ami                    = var.ubuntu_ami.id
  instance_type          = var.instance_type
  iam_instance_profile   = var.ec2_instance_profile
  key_name               = var.key_name
  subnet_id              = var.private_subnet_ids[count.index%length(var.private_subnet_ids)]
  source_dest_check      = false
  vpc_security_group_ids = [var.cluster_sg_id]
  user_data = var.install_k8s_user_data
  tags = {
    "Name" = "${var.cluster_prefix}-worker-${count.index}"
  }
}
