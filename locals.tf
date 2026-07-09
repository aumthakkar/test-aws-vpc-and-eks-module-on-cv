locals {
  public_subnet_cidr  = [for i in range(2, 255, 2) : cidrsubnet(var.vpc_cidr, 8, i)]
  private_subnet_cidr = [for i in range(1, 255, 2) : cidrsubnet(var.vpc_cidr, 8, i)]
}

locals {
  public_subnet_cidr_block  = var.auto_create_subnet_addresses ? local.public_subnet_cidr : var.public_subnet_cidr_addresses
  private_subnet_cidr_block = var.auto_create_subnet_addresses ? local.private_subnet_cidr : var.private_subnet_cidr_addresses
}

locals {
  cluster_security_groups = {
    public_sg = {
      name        = var.cluster_public_security_groups_name
      description = var.cluster_public_security_groups_desc
      tags = {
        Name = "${var.name_prefix}-public-sg"
      }
      ingress = {
        ssh = {
          from        = 22
          to          = 22
          protocol    = "tcp"
          cidr_blocks = var.ssh_access_ips
        }
      }
    }

    efs_sg = {
      name        = var.cluster_efs_security_group_name
      description = var.cluster_efs_security_group_desc
      tags = {
        Name = "${var.name_prefix}-efs-sg"
      }
      ingress = {
        nfs = {
          from        = 2049
          to          = 2049
          protocol    = "tcp"
          cidr_blocks = var.vpc_cidr
        }
      }
    }
  }
}

# Extract OIDC Provider from OIDC Provider ARN

locals {
  aws_iam_openid_connect_provider_extract = element(split("oidc-provider/", "${aws_iam_openid_connect_provider.oidc_provider.arn}"), 1)
}

