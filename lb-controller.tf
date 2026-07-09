

resource "helm_release" "lb_controller" {
  count = var.create_ingress_lb_controller ? 1 : 0

  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  namespace = "kube-system"

  set = [
    {
      name  = "image.repository"
      value = "602401143452.dkr.ecr.eu-north-1.amazonaws.com/amazon/aws-load-balancer-controller"
      # The above value is region based-Additional Reference: https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images
    },

    {
      name  = "serviceAccount.create"
      value = "true"
    },

    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller" # Must exactly match the SA role name set in the IAM Role
    },

    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" # results in - Annotations: eks.amazonaws.com/role-arn: arn:aws:iam::650251713601:role/web-identity-role
      value = "${aws_iam_role.lbc_iam_role[count.index].arn}"
    },

    {
      name  = "vpcId"
      value = "${aws_vpc.my_eks_vpc.id}"
    },

    {
      name  = "region"
      value = "${var.aws_region}"
    },

    {
      name  = "clusterName"
      value = "${aws_eks_cluster.my_eks_cluster.id}"
    }
  ]

  depends_on = [
    aws_eks_node_group.my_eks_private_nodegroup,
    aws_eks_node_group.my_eks_public_nodegroup,
    aws_iam_role_policy_attachment.lbc_iam_role_policy_attachment
  ]
}

