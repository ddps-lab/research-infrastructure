resource "aws_security_group" "ddps-cluster-sg" {
  name        = "terraform-eks-${var.cluster_name}"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.ddps.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "karpenter.sh/discovery" = var.cluster_name
  }
}