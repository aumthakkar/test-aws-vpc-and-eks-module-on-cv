
data "aws_eks_addon_version" "cloudwatch_latest_driver" {
  addon_name = "amazon-cloudwatch-observability"

  kubernetes_version = aws_eks_cluster.my_eks_cluster.version
  most_recent        = true
}

resource "aws_eks_addon" "my_cloudwatch_observability" {
  count = var.enable_cloudwatch_observability ? 1 : 0

  cluster_name = aws_eks_cluster.my_eks_cluster.name

  addon_name    = "amazon-cloudwatch-observability"
  addon_version = data.aws_eks_addon_version.cloudwatch_latest_driver.version

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  configuration_values = null

  tags = {
    Name = "${var.name_prefix}-cloudwatch-observability"
  }

  depends_on = [
    aws_eks_addon.my_eks_pod_identity_agent,
    aws_eks_pod_identity_association.my_cloudwatch_observability_pod_identity_association
  ]
}