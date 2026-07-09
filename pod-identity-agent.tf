data "aws_eks_addon_version" "pod_identity_agent_latest" {
  addon_name = "eks-pod-identity-agent"

  kubernetes_version = aws_eks_cluster.my_eks_cluster.version
  most_recent        = true

}

resource "aws_eks_addon" "my_eks_pod_identity_agent" {
  cluster_name = aws_eks_cluster.my_eks_cluster.name

  addon_name    = "eks-pod-identity-agent"
  addon_version = data.aws_eks_addon_version.pod_identity_agent_latest.version

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  configuration_values = null

  tags = {
    Name = "${var.name_prefix}-eks-pod-identity-agent"
  }
}