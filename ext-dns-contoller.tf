
resource "helm_release" "my_external_dns_controller" {
  count = var.create_external_dns_controller ? 1 : 0

  name      = "external-dns"
  namespace = "kube-system"

  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"

  set = [
    {
      name  = "image.repository"
      value = "registry.k8s.io/external-dns/external-dns"
    },
    {
      name  = "serviceAccount.create"
      value = "true"
    },
    {
      name  = "serviceAccount.name"
      value = "external-dns"
    },
    {
      name  = "provider.name"
      value = "aws"
    },
    {
      name  = "policy"
      value = "sync" # Default is 'upsert-only' which won't delete DNS records if the ingress resource is deleted from the eks-cluster
    }
  ]

  depends_on = [
    aws_iam_role_policy_attachment.my_ext_dns_iam_role_policy_attachment
  ]

}
