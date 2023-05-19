resource "local_file" "karpenter_deploy" {
  content = <<-EOT
        controller:
          logLevel: "debug"	
        serviceAccount:
          annotations:  
                eks.amazonaws.com/role-arn: ${aws_iam_role.karpenter_role.arn}
        clusterName: ${var.cluster_name}
        clusterEndpoint: ${module.eks.cluster_endpoint}
        
        # aws configuration
        
        aws:
          defaultInstanceProfile: ${aws_iam_instance_profile.karpenter.name}
    EOT
  # give the path to where you want to place the file. for example:
  filename = "karpenter-values.yaml"
}
