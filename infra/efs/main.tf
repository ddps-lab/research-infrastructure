resource "aws_security_group" "cluster_efs_sg" {
  ingress = [{
    cidr_blocks      = [var.vpc.cidr_block]
    description      = ""
    from_port        = 2049
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 2049
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
    "Name" = "${var.cluster_prefix}-cluster-${var.efs_for}-efs-sg"
  }
}

resource "aws_efs_file_system" "efs_filesystem" {
  creation_token = "${var.cluster_prefix}-${var.efs_for}-efs"
}

resource "aws_efs_mount_target" "efs_mount_target" {
  count = length(var.private_subnet_ids)
  file_system_id = aws_efs_file_system.efs_filesystem.id
  subnet_id = var.private_subnet_ids[count.index]
  security_groups = [aws_security_group.cluster_efs_sg.id]
}