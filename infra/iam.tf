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

locals {
  ingress-controller-policy-json = jsondecode(file("${path.module}/assets/iam_policy/ingress_controller_policy.json"))
}

resource "aws_iam_policy" "k8s-cluster-ingress-controller-iam-policy" {
  name = "${var.main_suffix}-k8s-cluster-ingress-controller-iam-policy"
  policy = jsonencode(local.ingress-controller-policy-json)
}

resource "aws_iam_role" "k8s-cluster-ec2role" {
  name = "${var.main_suffix}-k8s-cluster-e2c-role"
  assume_role_policy = data.aws_iam_policy_document.ec2-service-for-iam-role.json
}

resource "aws_iam_role_policy_attachment" "k8s-cluster-ec2role-attach-ssm-policy" {
  role = aws_iam_role.k8s-cluster-ec2role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "k8s-cluster-ec2role-attach-ec2-full-access" {
  role = aws_iam_role.k8s-cluster-ec2role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "k8s-cluster-ec2role-attach-route53-full-access" {
  role = aws_iam_role.k8s-cluster-ec2role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
}

resource "aws_iam_role_policy_attachment" "k8s-cluster-ec2role-attach-ingress-controller-policy" {
  role = aws_iam_role.k8s-cluster-ec2role.name
  policy_arn = aws_iam_policy.k8s-cluster-ingress-controller-iam-policy.arn
}


# resource "aws_iam_role_policy_attachment" "k8s-cluster-ec2role-attach-EFS-client-full-access-policy" {
#   role = aws_iam_role.k8s-cluster-ec2role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemClientFullAccess"
# }

resource "aws_iam_instance_profile" "k8s-cluster-ec2role-instance-profile" {
  name = "${var.main_suffix}-k8s-cluster-ec2-role-instnace-profile"
  role = aws_iam_role.k8s-cluster-ec2role.name
}

resource "aws_iam_role" "nat-ec2role" {
  name = "${var.main_suffix}-nat-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2-service-for-iam-role.json
}

resource "aws_iam_role_policy_attachment" "nat-ec2role-attach-ssm-policy" {
  role = aws_iam_role.nat-ec2role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "nat-ec2role-instance-profile" {
  name = "${var.main_suffix}-nat-ec2-role-instnace-profile"
  role = aws_iam_role.nat-ec2role.name
}