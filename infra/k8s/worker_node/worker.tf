resource "aws_instance" "worker_node" {
  count                  = var.worker_node_number
  ami                    = var.ubuntu_ami.id
  instance_type          = var.instance_type
  iam_instance_profile   = var.ec2_instance_profile
  key_name               = var.key_name
  subnet_id              = var.private_subnet_ids[count.index % length(var.private_subnet_ids)]
  source_dest_check      = false
  vpc_security_group_ids = [var.cluster_sg_id]
  tags = {
    "Name" : "${var.cluster_prefix}-worker-${count.index}"
    "sigs.k8s.io/cluster-api-provider-aws/role" : "node"
    "kubernetes.io/cluster/${var.cluster_prefix}" : "owned"
  }
  root_block_device {
    volume_size           = 50    # 볼륨 크기를 지정합니다.
    volume_type           = "gp2" # 볼륨 유형을 지정합니다.
    delete_on_termination = true  # 인스턴스가 종료될 때 볼륨도 함께 삭제되도록 설정합니다.
  }
}
