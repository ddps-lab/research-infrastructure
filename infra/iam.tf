data "aws_iam_policy_document" "ec2-service-for-iam-role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "k8s-cluster-ec2role" {
  name = "${var.cluster_prefix}-k8s-cluster-e2c-role"
  assume_role_policy = data.aws_iam_policy_document.ec2-service-for-iam-role.json
}

resource "aws_iam_role_policy_attachment" "k8s-cluster-ec2role-attach-ssm-policy" {
  role = aws_iam_role.k8s-cluster-ec2role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "k8s-cluster-ec2role-instance-profile" {
  name = "${var.cluster_prefix}-k8s-cluster-ec2-role-instnace-profile"
  role = aws_iam_role.k8s-cluster-ec2role.name
}

resource "aws_iam_role" "nat-ec2role" {
  name = "${var.cluster_prefix}-nat-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2-service-for-iam-role.json
}

resource "aws_iam_role_policy_attachment" "nat-ec2role-attach-ssm-policy" {
  role = aws_iam_role.nat-ec2role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "nat-ec2role-instance-profile" {
  name = "${var.cluster_prefix}-nat-ec2-role-instnace-profile"
  role = aws_iam_role.nat-ec2role.name
}