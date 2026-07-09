
resource "aws_iam_role" "my_eks_cluster_role" {
  name = "${var.name_prefix}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "${var.name_prefix}-eks-cluster-role"
  }
}

# Associate the above IAM role to both the AWS managed EKS IAM policies below
resource "aws_iam_role_policy_attachment" "eks-AmazonEKSClusterPolicy" {
  role       = aws_iam_role.my_eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSVPCResourceController" {
  role       = aws_iam_role.my_eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}