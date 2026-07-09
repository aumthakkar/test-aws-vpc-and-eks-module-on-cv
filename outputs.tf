
# === eks/outputs.tf ==== 

output "cluster_id" {
  description = "The name/id of the EKS Cluster"
  value       = aws_eks_cluster.my_eks_cluster.id
}

output "cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API."
  value       = aws_eks_cluster.my_eks_cluster.endpoint
}

output "cluster_arn" {
  description = "The ARN of the EKS Cluster"
  value       = aws_eks_cluster.my_eks_cluster.arn
}

output "cluster_cert_auth_data" {
  description = "Nested attribute containing certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster"
  value       = aws_eks_cluster.my_eks_cluster.certificate_authority[0].data
}

output "cluster_version" {
  description = "The Kubernetes server version for the EKS cluster."
  value       = aws_eks_cluster.my_eks_cluster.version
}

output "cluster_security_group_id" {
  value = [aws_eks_cluster.my_eks_cluster.vpc_config[0].security_group_ids]
}

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster."
  value       = aws_iam_role.eks_master_role.name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster."
  value       = aws_iam_role.eks_master_role.arn
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = aws_eks_cluster.my_eks_cluster.identity[0].oidc[0].issuer
}

output "cluster_primary_security_group_id" {
  description = "The cluster primary security group ID created by the EKS cluster on 1.14 or later. Referred to as 'Cluster security group' in the EKS console."
  value       = aws_eks_cluster.my_eks_cluster.vpc_config[0].cluster_security_group_id
}

# EKS Node Group Outputs - Public
output "node_group_public_id" {
  description = "Public Node Group ID"
  value       = aws_eks_node_group.my_eks_public_nodegroup.id
}

output "node_group_public_arn" {
  description = "Public Node Group ARN"
  value       = aws_eks_node_group.my_eks_public_nodegroup.arn
}

output "node_group_public_status" {
  description = "Public Node Group status"
  value       = aws_eks_node_group.my_eks_public_nodegroup.status
}

output "node_group_public_version" {
  description = "Public Node Group Kubernetes Version"
  value       = aws_eks_node_group.my_eks_public_nodegroup.version
}

# EKS Node Group Outputs - Private
output "node_group_private_id" {
  description = "Private Node Group ID"
  value       = aws_eks_node_group.my_eks_private_nodegroup.id
}

output "node_group_private_arn" {
  description = "Private Node Group ARN"
  value       = aws_eks_node_group.my_eks_private_nodegroup.arn
}

output "node_group_private_status" {
  description = "Private Node Group status"
  value       = aws_eks_node_group.my_eks_private_nodegroup.status
}

output "node_group_private_version" {
  description = "Private Node Group Kubernetes Version"
  value       = aws_eks_node_group.my_eks_private_nodegroup.version
}


# EKS IRSA related Outputs

output "aws_iam_openid_connect_provider_arn" {
  value = aws_iam_openid_connect_provider.oidc_provider.arn
}

output "aws_iam_openid_connect_provider_extract_from_arn" {
  value = local.aws_iam_openid_connect_provider_extract
}

# EKS-EBS-CSI-Addon related Outputs

output "ebs_eks_addon_arn" {
  value = aws_eks_addon.aws_ebs_csi_driver[*].arn
}

output "ebs_eks_addon_id" {
  value = aws_eks_addon.aws_ebs_csi_driver[*].id
}

# EKS-EFS-CSI-Addon related Outputs
output "efs_eks_addon_arn" {
  value = aws_eks_addon.aws_efs_csi_driver[*].arn
}

output "efs_eks_addon_id" {
  value = aws_eks_addon.aws_efs_csi_driver[*].id
}

# === vpc networking/outputs.tf === 

output "vpc_id" {
  value = aws_vpc.my_eks_vpc.id
}


output "public_subnets" {
  value = aws_subnet.my_public_subnets[*].id
}


output "private_subnets" {
  value = aws_subnet.my_private_subnets[*].id
}

output "vpc_cidr" {
  value = aws_vpc.my_eks_vpc.cidr_block
}

output "public_sg_ids" {
  value = [aws_security_group.cluster_sg["public_sg"].id]
}

output "efs_sg_ids" {
  value = [aws_security_group.cluster_sg["efs_sg"].id]
}

output "igw_id" {
  value = aws_internet_gateway.my_igw.id
}

# lbc Helm metadata outputs

output "lbc_helm_metadata" {
  value = helm_release.lb_controller[*].metadata

  description = "Metadata block outlining the status of the deployed Load Balancer Controller release."
}

output "ext_dns_helm_metadata" {
  value = helm_release.external_dns[*].metadata

  description = "Metadata block outlining the status of the deployed External DNS Controller release."
}