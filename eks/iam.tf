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

resource "aws_iam_role_policy_attachment" "eksClusterRole-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eksClusterRole.name
}

resource "aws_iam_role_policy_attachment" "eksClusterRole-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eksClusterRole.name
}

resource "aws_iam_role" "eksNodeRole" {
  name = "KarpenterNodeRole-${var.cluster_name}"

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
resource "aws_iam_role_policy_attachment" "eksNodeRole-AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.eksNodeRole.name
}

resource "aws_iam_policy" "ALBPolicy" {
  name        = "ALBPolicy-${var.cluster_name}"
  description = "karpenter policy"

  policy = file("assets/alb_iam_policy.json")
}

resource "aws_iam_role_policy_attachment" "alb-attach" {
  role       = aws_iam_role.eksNodeRole.name
  policy_arn = aws_iam_policy.ALBPolicy.arn
}

resource "aws_iam_policy" "KarpenterControllerPolicy" {
  name        = "KarpenterControllerPolicy-${var.cluster_name}"
  description = "karpenter policy"
  tags = {
    "karpenter.sh/discovery" = var.cluster_name
  }
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
      },
      {
        "Effect" : "Allow",
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Resource" : "*"
      }
    ]
  })
}

module "karpenter_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                          = "KarpenterControllerRole-${var.cluster_name}"
  attach_karpenter_controller_policy = true
  role_policy_arns = {
    policy = aws_iam_policy.KarpenterControllerPolicy.arn
  }
  karpenter_controller_cluster_name       = var.cluster_name
  karpenter_controller_node_iam_role_arns = [module.eks.eks_managed_node_groups["karpenter"].iam_role_arn]

  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["karpenter:karpenter"]
    }
  }
}

resource "aws_iam_instance_profile" "KarpenterNodeInstanceProfile" {
  name = "KarpenterNodeInstanceProfile-${var.cluster_name}"
  role = aws_iam_role.eksNodeRole.name
}
