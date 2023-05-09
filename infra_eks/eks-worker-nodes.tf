#
# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EKS Node Group to launch worker nodes
#

resource "aws_iam_role" "ddps-node" {
  name = "jg-eks-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "ddps-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.ddps-node.name
}

resource "aws_iam_role_policy_attachment" "ddps-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.ddps-node.name
}

resource "aws_iam_role_policy_attachment" "ddps-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.ddps-node.name
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.24"
  vpc_id          = aws_vpc.ddps.id
  subnet_ids      = aws_subnet.ddps[*].id

  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
  }
  tags = {
    "karpenter.sh/discovery" = var.cluster_name
  }
}
resource "aws_eks_node_group" "ddps" {
  cluster_name    = var.cluster_name
  node_group_name = "ddps"
  node_role_arn   = aws_iam_role.ddps-node.arn
  subnet_ids      = aws_subnet.ddps[*].id

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 2
  }
  ami_type       = "AL2_ARM_64"
  instance_types = ["t4g.medium"]

  depends_on = [
    aws_iam_role_policy_attachment.ddps-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.ddps-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.ddps-node-AmazonEC2ContainerRegistryReadOnly,
  ]
}
