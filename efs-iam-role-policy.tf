resource "aws_iam_role" "my_efs_csi_iam_role" {
  count = var.create_efs_csi_driver ? 1 : 0

  name = "${var.name_prefix}-efs-csi-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Sid    = "EFS_CSI_IAM_Role"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "${var.name_prefix}-efs-csi-iam-role"
  }
}


resource "aws_iam_role_policy_attachment" "eks_AmazonEFSCSIDriverPolicy" {
  count = var.create_efs_csi_driver ? 1 : 0

  role       = aws_iam_role.my_efs_csi_iam_role[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
}


resource "aws_eks_pod_identity_association" "my_efs_driver_pod_identity_association" {
  count = var.create_efs_csi_driver ? 1 : 0

  cluster_name = aws_eks_cluster.my_eks_cluster.name

  namespace       = "kube-system"
  service_account = "efs-csi-controller-sa"

  role_arn = aws_iam_role.my_efs_csi_iam_role[count.index].arn

  tags = {
    Name = "${var.name_prefix}-efs-csi-driver-pod-identity-association"
  }
}


