resource "aws_iam_role" "eksClusterRole" {
  name = "eksClusterRole-${var.cluster_name}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role" "eksNodeRole" {
  name = "eksNodeRole-${var.cluster_name}"

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

resource "aws_iam_role_policy_attachment" "eksNodeRole-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eksNodeRole.name
}

resource "aws_iam_role_policy_attachment" "eksNodeRole-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eksNodeRole.name
}

resource "aws_iam_role_policy_attachment" "eksNodeRole-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eksNodeRole.name
}
resource "aws_iam_role_policy_attachment" "eksNodeRole-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eksNodeRole.name
}

resource "aws_iam_policy" "ALBPolicy" {
  name        = "KarpenterControllerPolicy-${var.cluster_name}"
  description = "karpenter policy"

  policy = file("assets/alb_iam_policy.json")
}

resource "aws_iam_role_policy_attachment" "alb-attach" {
  role       = aws_iam_role.eksNodeRole.name
  policy_arn = aws_iam_policy.ALBPolicy.arn
}

resource "aws_iam_role" "KarpenterInstanceNodeRole" {
  name = "KarpenterInstanceNodeRole-${var.cluster_name}"

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
resource "aws_iam_role_policy_attachment" "karpenter-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.KarpenterInstanceNodeRole.name
}

resource "aws_iam_role_policy_attachment" "karpenter-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.KarpenterInstanceNodeRole.name
}

resource "aws_iam_role_policy_attachment" "karpenter-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.KarpenterInstanceNodeRole.name
}

resource "aws_iam_role_policy_attachment" "karpenter-AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.KarpenterInstanceNodeRole.name
}


resource "aws_iam_policy" "KarpenterControllerPolicy" {
  name        = "KarpenterControllerPolicy-${var.cluster_name}"
  description = "karpenter policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "ssm:GetParameter",
          "iam:PassRole",
          "ec2:DescribeImages",
          "ec2:RunInstances",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeAvailabilityZones",
          "ec2:DeleteLaunchTemplate",
          "ec2:CreateTags",
          "ec2:CreateLaunchTemplate",
          "ec2:CreateFleet",
          "ec2:DescribeSpotPriceHistory",
          "pricing:GetProducts"
        ],
        "Effect" : "Allow",
        "Resource" : "*",
        "Sid" : "Karpenter"
      },
      {
        "Action" : "ec2:TerminateInstances",
        "Condition" : {
          "StringLike" : {
            "ec2:ResourceTag/Name" : "*karpenter*"
          }
        },
        "Effect" : "Allow",
        "Resource" : "*",
        "Sid" : "ConditionalEC2Termination"
      }
    ]
  })
}

resource "aws_iam_role" "KarpenterControllerRole" {
  name = "KarpenterControllerRole-${var.cluster_name}"
}

resource "aws_iam_role_policy_attachment" "karpenter-attach" {
  role       = aws_iam_role.KarpenterControllerRole.name
  policy_arn = aws_iam_policy.KarpenterControllerPolicy.arn
}
