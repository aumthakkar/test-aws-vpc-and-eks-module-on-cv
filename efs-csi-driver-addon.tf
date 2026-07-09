
data "aws_eks_addon_version" "efs_csi_driver_latest" {
  addon_name = "aws-efs-csi-driver"

  kubernetes_version = aws_eks_cluster.my_eks_cluster.version
  most_recent        = true

}

resource "aws_eks_addon" "my_efs_csi_driver" {
  count = var.create_efs_csi_driver ? 1 : 0

  cluster_name = aws_eks_cluster.my_eks_cluster.name

  addon_name    = "aws-efs-csi-driver"
  addon_version = data.aws_eks_addon_version.efs_csi_driver_latest.version

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  configuration_values = jsonencode({
    controller = {
      replicaCount = 1
    }
  })

  tags = {
    Name = "${var.name_prefix}-efs-csi-driver"
  }

  depends_on = [
    aws_eks_addon.my_eks_pod_identity_agent,
    aws_eks_pod_identity_association.my_efs_driver_pod_identity_association
  ]
}

