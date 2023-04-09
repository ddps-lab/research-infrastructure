resource "aws_security_group" "master_sg" {
  ingress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 22
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 22
    }, {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 6443
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 6443
  }]
  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
  vpc_id = var.vpc.id

  tags = {
    "Name" = "${var.cluster_prefix}-master-node-sg"
  }
}


resource "aws_instance" "master_node" {
  count                  = var.master_node_number
  ami                    = var.ubuntu_ami.id
  instance_type          = var.instance_type
  iam_instance_profile   = var.ec2_instance_profile
  key_name               = var.key_name
  subnet_id              = var.private_subnet_ids[count.index % length(var.private_subnet_ids)]
  vpc_security_group_ids = [var.cluster_sg_id, aws_security_group.master_sg.id]
  source_dest_check      = false
  tags = {
    "Name" : "${var.cluster_prefix}-master-${count.index}"
    "sigs.k8s.io/cluster-api-provider-aws/role" : "control-plane"
    "kubernetes.io/cluster/${var.cluster_prefix}" : "owned"
  }
  root_block_device {
    volume_size           = 50    # 볼륨 크기를 지정합니다.
    volume_type           = "gp2" # 볼륨 유형을 지정합니다.
    delete_on_termination = true  # 인스턴스가 종료될 때 볼륨도 함께 삭제되도록 설정합니다.
  }
}
