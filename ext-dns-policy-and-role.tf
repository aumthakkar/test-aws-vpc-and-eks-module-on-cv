
resource "aws_iam_policy" "my_ext_dns_iam_policy" {
  count = var.create_external_dns_controller ? 1 : 0

  name        = "${var.name_prefix}-AllowExternalDNSUpdates"
  path        = "/"
  description = "External DNS IAM Policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:ChangeResourceRecordSets"
        ],
        "Resource" : [
          "arn:aws:route53:::hostedzone/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets"
        ],
        "Resource" : ["*"]
      }
    ]
  })

  tags = {
    tag-key = "Allow-External-DNS-Updates"
  }
}

resource "aws_iam_role" "my_ext_dns_iam_role" {
  count = var.create_external_dns_controller ? 1 : 0

  name = "${var.name_prefix}-external-dns-controller-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Sid    = "Ext_DNS_IAM_Role"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "${var.name_prefix}-external-dns-controller-iam-role"
  }

}

resource "aws_iam_role_policy_attachment" "my_ext_dns_iam_role_policy_attachment" {
  count = var.create_external_dns_controller ? 1 : 0

  policy_arn = aws_iam_policy.my_ext_dns_iam_policy[count.index].arn
  role       = aws_iam_role.my_ext_dns_iam_role[count.index].name
}


resource "aws_eks_pod_identity_association" "my_ext_dns_controller_eks_pia" {
  count = var.create_external_dns_controller ? 1 : 0

  cluster_name = aws_eks_cluster.my_eks_cluster.name

  namespace       = "kube-system"
  service_account = "external-dns"

  role_arn = aws_iam_role.my_ext_dns_iam_role[count.index].arn

  tags = {
    Name = "${var.name_prefix}-ext-dns-pod-identity-association"
  }
}





