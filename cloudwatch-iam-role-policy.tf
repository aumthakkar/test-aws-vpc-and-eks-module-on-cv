
resource "aws_iam_role" "my_cloudwatch_csi_iam_role" {
  count = var.create_ebs_csi_driver ? 1 : 0

  name = "${var.name_prefix}-cloudwatch-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Sid    = "CW_CSI_IAM_Role"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "${var.name_prefix}-cloudwatch-csi-iam-role"
  }
}

resource "aws_iam_role_policy_attachment" "eks_CloudWatchAgentServerPolicy" {
  count = var.create_cloudwatch_observability_and_fluentbit_agents ? 1 : 0

  role       = aws_iam_role.my_cloudwatch_csi_iam_role[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"

}

# Attaching XRay policy to automatically discover & monitor application performance (Uses CW app signals which uses OT)
resource "aws_iam_role_policy_attachment" "eks_AWSXrayWriteOnlyAccess" {
  count = var.create_cloudwatch_observability_and_fluentbit_agents ? 1 : 0

  role       = aws_iam_role.my_cloudwatch_csi_iam_role[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"

}

resource "aws_eks_pod_identity_association" "my_cloudwatch_driver_pod_identity_association" {
  count = var.create_efs_csi_driver ? 1 : 0

  cluster_name = aws_eks_cluster.my_eks_cluster.name

  namespace       = "kube-system"
  service_account = "cloudwatch-agent"

  role_arn = aws_iam_role.my_cloudwatch_csi_iam_role[count.index].arn

  tags = {
    Name = "${var.name_prefix}-cloudwatch-csi-driver-pod-identity-association"
  }
}