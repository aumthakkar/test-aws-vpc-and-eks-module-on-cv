

## Example Usage:

```terraform
module "eks_cluster" {
  source = "git::https://github.com/aumthakkar/aws-vpc-and-eks-module.git"

  name_prefix = local.name
  aws_region  = var.aws_region

  # networking related values
  vpc_cidr = var.vpc_cidr

  auto_create_subnet_addresses = true

  public_subnet_count                  = 2
  custom_public_subnet_cidr_addresses  = var.custom_public_subnet_cidr_addresses
  private_subnet_count                 = 2
  custom_private_subnet_cidr_addresses = var.custom_private_subnet_cidr_addresses

  cluster_public_security_group_name = "${local.name}-${var.cluster_security_group_name}"
  cluster_public_security_group_desc = "${local.name} ${var.cluster_public_security_group_desc}"
  ssh_access_ips                     = var.ssh_access_ips

  cluster_efs_security_group_name = "${local.name}-${var.cluster_efs_security_group_name}"
  cluster_efs_security_group_desc = "${local.name}-${var.cluster_efs_security_group_desc}"

  # eks-cluster related values
  cluster_name        = "${local.name}-eksdemo"
  eks_cluster_version = "1.33"

  enable_cloudwatch_observability = true
  create_ebs_csi_driver           = true
  create_efs_csi_driver           = true
  create_ingress_lb_controller    = true
  create_external_dns_controller  = false

  cluster_service_ipv4_cidr            = "172.20.0.0/16"
  cluster_endpoint_private_access      = false
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  eks_public_nodegroup_name           = "${local.name}-public-nodegroup" # Optional - If not, TF will assign a random unique name
  public_nodegroup_desired_size       = 1                                # Required
  public_nodegroup_min_size           = 1                                # Required
  public_nodegroup_max_size           = 2                                # Required
  public_nodegroup_max_unavail_pctage = 50                               # Optional

  public_nodegroup_ami_type       = "AL2023_x86_64_STANDARD"  # Optional - defaults to "AL2023_x86_64_STANDARD"
  public_nodegroup_capacity_type  = "ON_DEMAND"               # Optional - defaults to "ON_DEMAND"
  public_nodegroup_disk_size      = 20                        # Optional - defaults to 20 for all others but 50 for Windows
  public_nodegroup_instance_types = ["t3.large"]              # Optional - defaults to t3.medium

  eks_private_nodegroup_name           = "${local.name}-private-nodegroup"
  private_nodegroup_desired_size       = 1  # Required
  private_nodegroup_min_size           = 1  # Required
  private_nodegroup_max_size           = 2  # Required
  private_nodegroup_max_unavail_pctage = 50 # Optional

  private_nodegroup_ami_type       = "AL2023_x86_64_STANDARD"  # Optional - defaults to "AL2023_x86_64_STANDARD"
  private_nodegroup_capacity_type  = "ON_DEMAND"               # Optional - defaults to "ON_DEMAND"
  private_nodegroup_disk_size      = 20                        # Optional - defaults to 20 for all others and 50 for Windows
  private_nodegroup_instance_types = ["t3.large"]              # Optional - defaults to t3.medium

}

```

## Description

This repository provisions a fully automated, production-ready AWS EKS cluster across public and private subnets, complete with necessary storage drivers and ingress controllers.

> **Architecture Note:** This deployment utilizes **AWS EKS Pod Identity** instead of the legacy IAM Roles for Service Accounts (IRSA) approach. Pod permissions (like the EBS/EFS CSI drivers) are mapped directly via pod identity associations, eliminating the need to manage an IAM OIDC provider or annotate Kubernetes ServiceAccounts.

-    This module creates an AWS VPC in which it then creates an EKS cluster with conditional selections to create an EBS driver, EFS driver, Amazon Cloudwatch Observability addons, Load Balancer Ingress Controller and External DNS Controller.
     - All the addons are created in the kube-system namespace.
     - Each addon or agent listed above, can be individually enabled or disabled based on the boolean value passed to its respective argument in the root module.
     - Based on the addons/agents selected to be installed, it will create the right IAM permissions suitable to run those appropriately. 
         
-    The module can automatically calculate IP addresses and provision the requested number of subnets using the cidrsubnet() function, based on the root module's VPC CIDR block. 
     -    Alternatively, if you prefer to use custom subnet CIDR blocks, set the auto_create_subnet_addresses argument to false and define your custom ranges in your root module's .tfvars file.
     -    These subnets are then created in the automatically selected and shuffled Availability Zones. 
-    This module also creates an Ingress Class with the controller type of Application Load Balancer. 

## Requirements

-    The EBS and EFS driver add-ons depend directly on the public and private EKS node groups. Consequently, these add-ons will only be provisioned after both node groups have been successfully created.

##### Version Requirements

| Name       | Version      |
| :--------- | :----------- |
| terraform  | >= 1.0.0     |
| aws        | >= 5.9       |
| kubernetes | >= 2.7       |
| helm       | >= 3.0.1     |
| http       | >= 3.5       |

## Inputs

| Name                                                 | Type         | Description                                                                                                                                  |
| :--------------------------------------------------- | :----------- | :------------------------------------------------------------------------------------------------------------------------------------------- |
| name_prefix                                          | string       | Name prefix to assign to your resource names.                                                                                                |
|                                                      |              |                                                                                                                                              |
| VPC related Inputs:                                  |              |                                                                                                                                              |
| aws_region                                           | string       | The AWS region for your VPC.                                                                                                                 |
| vpc_cidr                                             | string       | The VPC_CIDR of your setup.                                                                                                                  |
| auto_create_subnet_addresses                         | boolean      | A value of 'true' will automatically create the subnet IP addresses, a value of 'false' will abstain from creating the subnet IP addressses. |
| public_subnet_count                                  | number       | Number of public subnets to create.                                                                                                          |
| custom_public_subnet_cidr_addresses                         | list(string)       | To be entered manually if auto_create_subnet_addresses is set to false.                                                                      |
| private_subnet_count                                 | number       | Number of private subnets to create.                                                                                                         |
| custom_private_subnet_cidr_addresses                        | list(string)       | To be entered manually if auto_create_subnet_addresses is set to false.                                                                      |
| cluster_public_security_group_name                  | string       | Public Security Groups name.                                                                                                                 |
| cluster_public_security_group_desc                  | string       | Public Security Groups description.                                                                                                          |
| ssh_access_ips                                       | string       | IP address CIDR block defined in Inbound addresses to the public security group.                                                              |
| cluster_efs_security_group_name                      | string       | EFS security group name of your cluster.                                                                                                     |
| cluster_efs_security_group_desc                      | string       | EFS security group description of your cluster.                                                                                              |
|                                                      |              |                                                                                                                                              |
| EKS Cluster related Inputs:                          |              |                                                                                                                                              |
| cluster_name                                         | string       | EKS Cluster name.                                                                                                                            |
| eks_cluster_version                                  | string       | EKS Cluster version to be created.                                                                                                           |
|                                                      |              |                                                                                                                                              |
| enable_cloudwatch_observability | boolean      | A value of 'true' will create the CloudWatch and Fluentbit Agents, and a value of 'false' will skip its creation.                   |
| create_ebs_csi_driver                                | boolean      | A value of 'true' will create the EBS CSI Driver, and a value of 'false' will skip its creation.                                      |
| create_efs_csi_driver                                | boolean      | A value of 'true' will create the EFS CSI Driver, and a value of 'false' will skip its creation.                                      |
| create_ingress_lb_controller                         | boolean      | A value of 'true' will create the Ingress Load Balancer Controller, and a value of 'false' will skip its creation.                    |
| create_external_dns_controller                       | boolean      | A value of 'true' will create the External DNS Controller, and a value of 'false' will skip its creation.                             |
|                                                      |              |                                                                                                                                              |
| cluster_service_ipv4_cidr                            | string       | The CIDR block to assign Kubernetes pod and service IP addresses from.                                                                       |
| cluster_endpoint_private_access                      | boolean      | A value of 'true' will enable the Amazon EKS private API server endpoint and a value of 'false' will disable it.                             |
| cluster_endpoint_public_access                       | boolean      | A value of 'true' will enable the Amazon EKS public API server endpoint and a value of 'false' will disable it.                              |
| cluster_endpoint_public_access_cidrs                 | list(string) | Specifies the list of CIDR blocks allowed to access the EKS public API server endpoint when enabled. EKS defaults this value to 0.0.0.0/0."                |
|                                                      |              |                                                                                                                                              |
| EKS nodegroup related inputs:                        |              |                                                                                                                                              |
| eks_public_nodegroup_name                            | string       | Name assigned to your EKS public nodegroup.                                                                                                  |
| public_nodegroup_ami_type                            | string       | AMI type of the nodegroup worker node instances.                                                                                             |
| public_nodegroup_capacity_type                       | string       | Type of capacity of the Node group instances. Valid values - ON_DEMAND, SPOT.                                                                |
| public_nodegroup_disk_size                           | number       | Disk size in GiB for worker nodes. Defaults to 50 for Windows and 20 for all other node group types.                                              |
| public_nodegroup_instance_types                      | string       | List of instance types associated wih the Node groups Defaults to "t3.medium".                                                               |
|                                                      |              |                                                                                                                                              |
| public_nodegroup_desired_size                        | number       | Desired number of worker nodes.                                                                                                              |
| public_nodegroup_max_size                            | number       | Maximum number of worker nodes.                                                                                                              |
| public_nodegroup_min_size                            | number       | Minimum number of worker nodes.                                                                                                              |
| public_node_max_unavail_pctage                       | number       | Maxiumum percentage of unavailable worker nodes during group update.                                                                      |

## Resources

| Name                                               | Type        | Description                                                                                                                                                                                        |
| :------------------------------------------------- | :---------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| VPC Resources:                                     |             |                                                                                                                                                                                                    |
| aws_vpc.my_eks_vpc                                 | resource    | AWS VPC.                                                                                                                                                                                           |
| aws_availability_zones.available                    | data source | Data source to get all the possible AZ s from an AWS region.                                                                                                                                       |
| aws_subnet.my_public_subnets                      | resource    | Public Subnets of the VPC.                                                                                                                                                                         |
| aws_route_table.my_public_route_table                 | resource    | Public Route Table.                                                                                                                                                                                |
| aws_internet_gateway.my_igw                        | resource    | Internet Gateway.                                                                                                                                                                                  |
| aws_subnet.my_private_subnets                     | resource    | Private Subnets.                                                                                                                                                                                   |
| aws_default_route_table.my_default_private_route_table | resource    | Default Private Route Table.                                                                                                                                                                       |
| aws_route_table.my_private_route_table                | resource    | Private Route Table.                                                                                                                                                                               |
| aws_eip.my_nat_gw_eip                                 | resource    | NAT Gateway Elastic IP.                                                                                                                                                                            |
| aws_nat_gateway.my_nat_gateway                     | resource    | NAT Gateway.                                                                                                                                                                                       |
| aws_security_group.cluster_sg                      | resource    | AWS EKS Cluster Security Group.                                                                                                                                                                    |
|                                                    |             |                                                                                                                                                                                                    |
## Resources

| Name                                               | Type        | Description                                                                                                                                                                                        |
| :------------------------------------------------- | :---------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **VPC Resources:**                                 |             |                                                                                                                                                                                                    |
| aws_vpc.my_eks_vpc                                 | resource    | AWS VPC.                                                                                                                                                                                           |
| aws_availability_zones.available                    | data source | Data source to get all the possible AZs from an AWS region.                                                                                                                                       |
| aws_subnet.my_public_subnets                      | resource    | Public Subnets of the VPC.                                                                                                                                                                         |
| aws_route_table.my_public_route_table                 | resource    | Public Route Table.                                                                                                                                                                                |
| aws_internet_gateway.my_igw                        | resource    | Internet Gateway.                                                                                                                                                                                  |
| aws_subnet.my_private_subnets                     | resource    | Private Subnets.                                                                                                                                                                                   |
| aws_default_route_table.my_default_private_route_table | resource    | Default Private Route Table.                                                                                                                                                                       |
| aws_route_table.my_private_route_table                | resource    | Private Route Table.                                                                                                                                                                               |
| aws_eip.my_nat_gw_eip                                 | resource    | NAT Gateway Elastic IP.                                                                                                                                                                            |
| aws_nat_gateway.my_nat_gateway                     | resource    | NAT Gateway.                                                                                                                                                                                       |
| aws_security_group.cluster_sg                      | resource    | AWS EKS Cluster Security Group.                                                                                                                                                                    |
|                                                    |             |                                                                                                                                                                                                    |
| **IAM Resources:**                                 |             |                                                                                                                                                                                                    |
| aws_iam_role.my_eks_cluster_role                       | resource    | AWS EKS Master IAM role with **AmazonEKSClusterPolicy** and **AmazonEKSVPCResourceController** IAM Policies attached.                                                                                      |
| aws_iam_role.eks_nodegroup_role                    | resource    | AWS EKS Node Group IAM role with the following IAM Policies attached: **AmazonEKSWorkerNodePolicy, AmazonEKS_CNI_Policy, AmazonEC2ContainerRegistryReadOnly, AmazonEBSCSIDriverPolicy, AmazonEFSCSIDriverPolicy** and **AmazonSSMManagedInstanceCore**. |
| http.my_lbc_iam_policy                                | data source | Load Balancer IAM policy.                                                                                                                                                                          |
| aws_iam_role.my_lbc_iam_role                          | resource    | Load Balancer IAM role.                                                                                                                                                                            |
| aws_iam_role.my_ext_dns_iam_role                      | resource    | External DNS Role with an IAM policy of ChangeResourceRecordSets, ListHostedZones & ListResourceRecordSets permissions.                                                                            |
| aws_iam_role.my_ebs_csi_iam_role                   | resource    | IAM role for the EBS CSI Driver with **AmazonEBSCSIDriverPolicy** attached. Used via Pod Identity.                                                                                                  |
| aws_iam_role.my_efs_csi_iam_role                   | resource    | IAM role for the EFS CSI Driver with **AmazonEFSCSIDriverPolicy** attached. Used via Pod Identity.                                                                                                  |
|                                                    |             |                                                                                                                                                                                                    |
| **EKS Cluster Resources:**                         |             |                                                                                                                                                                                                    |
| aws_eks_cluster.my_eks_cluster                     | resource    | AWS EKS cluster.                                                                                                                                                                                   |
| aws_eks_node_group.my_eks_public_nodegroup         | resource    | Public EKS Node Group.                                                                                                                                                                             |
| aws_eks_node_group.my_eks_private_nodegroup        | resource    | Private Node Group.                                                                                                                                                                                |
| aws_eks_addon.my_eks_pod_identity_agent            | resource    | EKS Addon for AWS EKS Pod Identity Agent to manage pod runtime permissions.                                                                                                                        |
| aws_eks_addon.my_ebs_csi_driver                   | resource    | EKS Addon for EBS CSI Driver.                                                                                                                                                                      |
| aws_eks_addon.my_efs_csi_driver                   | resource    | EKS Addon for EFS CSI Driver.                                                                                                                                                                      |
| helm_release.my_lb_controller                         | resource    | Helm release to install the Load Balancer Controller.                                                                                                                                              |
| helm_release.my_external_dns_controller                          | resource    | Helm release to install the External DNS controller.                                                                                                                                               |

## Outputs

| Name                                             | Type         | Description                                                                                                                                                     |
| :----------------------------------------------- | :----------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| VPC related Outputs:                             |              |                                                                                                                                                                 |
| vpc_id                                           | string       | VPC identifier.                                                                                                                                                 |
| public_subnets                                   | list(string) | List of public subnets.                                                                                                                                         |
| private_subnets                                  | list(string) | List of private subnets.                                                                                                                                        |
| vpc_cidr                                         | string       | VPC CIDR block.                                                                                                                                                 |
| public_sg_ids                                    | list(string) | List of Public Security Group Ids.                                                                                                                              |
| efs_sg_ids                                       | list(string) | Lit of EFS Security Group Ids.                                                                                                                                  |
| igw_id                                           | string       | Internet Gateway ID.                                                                                                                                            |
|                                                  |              |                                                                                                                                                                 |
| EKS Cluster related Outputs:                     |              |                                                                                                                                                                 |
| cluster_id                                       | string       | The name/id of the EKS cluster.                                                                                                                                 |
| cluster_endpoint                                 | string       | The endpoint of your EKS Kubernetes API.                                                                                                                        |
| cluster_arn                                      | string       | The ARN of the EKS cluster.                                                                                                                                     |
| cluster_cert_auth_data                           | string       | Nested attribute containing certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster. |
| cluster_verion                                   | string       | The Kubernetes server version for the EKS cluster.                                                                                                              |
| cluster_security_group_id                        | list         | EKS cluster security group id.                                                                                                                                  |
| cluster_iam_role_name                            | string       | IAM role ARN of the EKS cluster.                                                                                                                                |
| cluster_oidc_issuer_url                          | string       | The URL on the EKS cluster OIDC Issuer.                                                                                                                         |
| cluster_primary_security_group_id                | string       | The cluster primary security group ID created by the EKS cluster on 1.14 or later. Referred to as 'Cluster security group' in the EKS console.                  |
| node_group_public_id                             | string       | Public Node Group ID.                                                                                                                                           |
| node_group_public_arn                            | string       | Public Node Group ARN.                                                                                                                                          |
| node_group_public_status                         | string       | Public Node Group status                                                                                                                                        |
| node_group_public_version                        | string       | Public Node Group Kubernetes Version                                                                                                                            |
| node_group_private_id                            | string       | Private Node Group ID.                                                                                                                                          |
| node_group_private_arn                           | string       | Private Node Group ARN.                                                                                                                                         |
| node_group_private_status                        | string       | Private Node Group status.                                                                                                                                      |
| node_group_private_version                       | string       | Private Node Group Kubernetes Version.                                                                                                                          |
| lbc_helm_metadata                                | list(object) | Metadata block outlining the status of the deployed Load Balancer Controller release.                                                                           |
| ext_dns_helm_metadata                            | list(object) | Metadata block outlining the status of the deployed External DNS Controller release.                                                                            |
|                                                  |              |                                                                                                                                                                 |
| EKS-EBS-CSI-Addon related Outputs:                |              |                                                                                                                                                                 |
| ebs_eks_addon_arn                                | string       | EBS CSI driver ARN.                                                                                                                                             |
| ebs_eks_addon_id                                 | string       | EBS CSI driver Id.                                                                                                                                              |
|                                                  |              |                                                                                                                                                                 |
| EKS-EFS-CSI-Addon related Outputs:               |              |                                                                                                                                                                 |
| efs_eks_addon_arn                                | string       | EFS CSI driver ARN.                                                                                                                                             |
| efs_eks_addon_id                                 | string       | EFS CSI driver Id.                                                                                                                                              |