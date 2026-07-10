resource "aws_iam_role" "my_ebs_csi_iam_role" {
  count = var.create_ebs_csi_driver ? 1 : 0

  name = "${var.name_prefix}-ebs-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Sid    = "EBS_CSI_IAM_Role"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "${var.name_prefix}-ebs-csi-iam-role"
  }
}

resource "aws_iam_role_policy_attachment" "eks_AmazonEBSCSIDriverPolicy" {
  count = var.create_ebs_csi_driver ? 1 : 0

  role       = aws_iam_role.my_ebs_csi_iam_role[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"

}

resource "aws_eks_pod_identity_association" "my_ebs_driver_pod_identity_association" {
  count = var.create_ebs_csi_driver ? 1 : 0

  cluster_name = aws_eks_cluster.my_eks_cluster.name

  namespace       = "kube-system"
  service_account = "ebs-csi-controller-sa"

  role_arn = aws_iam_role.my_ebs_csi_iam_role[count.index].arn

  tags = {
    Name = "${var.name_prefix}-ebs-csi-driver-pod-identity-association"
  }
}



