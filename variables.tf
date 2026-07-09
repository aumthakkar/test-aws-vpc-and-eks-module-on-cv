
# === eks/variables.tf ====

# EKS Cluster Input Variables

variable "cluster_name" {}
variable "name_prefix" {}

variable "eks_cluster_version" {
  description = "Kubernetes minor version to use for the EKS cluster (for example 1.21)"
}

variable "cluster_service_ipv4_cidr" {
  description = "service ipv4 cidr for the kubernetes cluster"
  type        = string
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled."
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled. When it's set to `false` ensure to have a proper private access with `cluster_endpoint_private_access = true`."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint."
  type        = list(string)
}

# variable "public_subnets" {}

# variable "private_subnets" {}

# EKS Public Node Group Variables

variable "eks_public_nodegroup_name" {}
variable "public_nodegroup_ami_type" {}
variable "public_nodegroup_capacity_type" {}
variable "public_nodegroup_disk_size" {
  type = number
}
variable "public_nodegroup_instance_types" {
  type = list(string)
}

variable "public_nodegroup_desired_size" {
  type = number
}
variable "public_nodegroup_max_size" {
  type = number
}
variable "public_nodegroup_min_size" {
  type = number
}
variable "public_nodegroup_max_unavail_pctage" {
  type = number
}


# EKS Private Node Group variables

variable "eks_private_nodegroup_name" {}
variable "private_nodegroup_ami_type" {}
variable "private_nodegroup_capacity_type" {}
variable "private_nodegroup_disk_size" {}
variable "private_nodegroup_instance_types" {
  type = list(string)
}

variable "private_nodegroup_desired_size" {}
variable "private_nodegroup_max_size" {}
variable "private_nodegroup_min_size" {}
variable "private_nodegroup_max_unavail_pctage" {}

# === networking/variables.tf ====

variable "aws_region" {

}
variable "vpc_cidr" {}

variable "public_subnet_count" {
  type = number
}

variable "private_subnet_count" {
  type = number
}

variable "cluster_public_security_groups_name" {}
variable "cluster_public_security_groups_desc" {}

variable "ssh_access_ips" {}

variable "cluster_efs_security_group_name" {}
variable "cluster_efs_security_group_desc" {}

variable "auto_create_subnet_addresses" {
  type        = bool
  description = "To get decision about auto creating subnet cidr addresses"
}

variable "public_subnet_cidr_addresses" {
  type        = list(string)
  description = "If auto_create_subnet_address var is set to false, users to manually input subnet cidr address(es) in a list"
}

variable "private_subnet_cidr_addresses" {
  type        = list(string)
  description = "If auto_create_subnet_address var is set to false, users to manually input subnet cidr address(es) in a list"
}

# Cloudwatch, EBS, EFS and Load-Balancer EKS Addon related Variables
variable "create_cloudwatch_observability_and_fluentbit_agents" {
  type = bool

  description = "Variable to decide if CloudwWatch Observability Agent needs to be installed."
}

variable "create_ebs_csi_driver" {
  type = bool

  description = "Variable to decide if the EBS-CSI driver needs to be installed."
}

variable "create_efs_csi_driver" {
  type = bool

  description = "Variable to decide if the EFS-CSI driver needs to be installed."
}

variable "create_ingress_lb_controller" {
  type = bool

  description = "Variable to decide if the Load Balancer Ingress Controller needs to be installed."
}

variable "create_external_dns_controller" {
  type = bool

  description = "Variable to decide if the External DNS Controller needs to be installed."
}


