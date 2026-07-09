
data "http" "my_lbc_iam_policy" {
  count = var.create_ingress_lb_controller ? 1 : 0

  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"

  # Optional request headers
  request_headers = {
    Accept = "application/json"
  }
}

resource "aws_iam_policy" "my_lbc_iam_policy" {
  count = var.create_ingress_lb_controller ? 1 : 0

  name        = "${var.name_prefix}-lbc-iam-policy"
  path        = "/"
  description = "IAM Policy for the Load Balancer Controller"

  policy = data.http.my_lbc_iam_policy[count.index].response_body
}


resource "aws_iam_role" "my_lbc_iam_role" {
  count = var.create_ingress_lb_controller ? 1 : 0

  name = "${var.name_prefix}-lbc-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "${var.name_prefix}-lbc-iam-role"
  }
}

resource "aws_iam_role_policy_attachment" "my_lbc_iam_role_policy_attachment" {
  count = var.create_ingress_lb_controller ? 1 : 0

  policy_arn = aws_iam_policy.my_lbc_iam_policy[count.index].arn
  role       = aws_iam_role.my_lbc_iam_role[count.index].name
}

resource "aws_eks_pod_identity_association" "my_lbc_driver_eks_pia" {
  count = var.create_ingress_lb_controller ? 1 : 0

  cluster_name = aws_eks_cluster.my_eks_cluster.name

  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"

  role_arn = aws_iam_role.my_lbc_iam_role[count.index].arn

  tags = {
    Name = "${var.name_prefix}-lbc-pod-identity-association"
  }
}