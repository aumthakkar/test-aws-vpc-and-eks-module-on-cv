

## Example Usage:

```terraform
module "eks_cluster" {
  source = "github.com/aumthakkar/aws-vpc-and-eks-module.git"

  name_prefix = local.name
  aws_region  = var.aws_region

  # networking related values
  vpc_cidr = var.vpc_cidr

  auto_create_subnet_addresses = true

  public_subnet_count           = 2
  public_subnet_cidr_addresses  = var.public_subnet_cidr_addresses
  private_subnet_count          = 2
  private_subnet_cidr_addresses = var.private_subnet_cidr_addresses

  cluster_public_security_groups_name = "${local.name}-${var.cluster_security_groups_name}"
  cluster_public_security_groups_desc = "${local.name} ${var.cluster_public_security_groups_desc}"
  ssh_access_ips                      = var.ssh_access_ips

  cluster_efs_security_group_name = "${local.name}-${var.cluster_efs_security_group_name}"
  cluster_efs_security_group_desc = "${local.name} ${var.cluster_efs_security_group_desc}"

  # eks-cluster related values
  cluster_name        = "${local.name}-eksdemo"
  eks_cluster_version = "1.32"

  create_cloudwatch_observability_and_fluentbit_agents = true
  create_ebs_csi_driver                                = true
  create_efs_csi_driver                                = true
  create_ingress_lb_controller                         = true
  create_external_dns_controller                       = true

  cluster_service_ipv4_cidr            = "172.20.0.0/16"
  cluster_endpoint_private_access      = false
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  eks_public_nodegroup_name           = "${local.name}-public-nodegroup" # Optional - TF will assign a random unique name
  public_nodegroup_desired_size       = 1                                # Required
  public_nodegroup_min_size           = 1                                # Required
  public_nodegroup_max_size           = 2                                # Required
  public_nodegroup_max_unavail_pctage = 50                               # Optional

  public_nodegroup_ami_type       = "AL2_x86_64"  # Optional 
  public_nodegroup_capacity_type  = "ON_DEMAND"   # Optional
  public_nodegroup_disk_size      = 20            # Optional - defaults to 20 for all others but 50 for Windows
  public_nodegroup_instance_types = ["t3.large"]  # Optional - defaults to t3.medium

  eks_private_nodegroup_name           = "${local.name}-private-nodegroup"
  private_nodegroup_desired_size       = 1  # Required
  private_nodegroup_min_size           = 1  # Required
  private_nodegroup_max_size           = 2  # Required
  private_nodegroup_max_unavail_pctage = 50 # Optional

  private_nodegroup_ami_type       = "AL2_x86_64"  # Optional
  private_nodegroup_capacity_type  = "ON_DEMAND"   # Optional
  private_nodegroup_disk_size      = 20            # Optional
  private_nodegroup_instance_types = ["t3.large"]  # Optional - defaults to t3.medium

}

```

## Description

-    This module creates an AWS VPC in which it also creates an EKS cluster with conditional selections to create an EBS driver, EFS driver, Amazon Cloudwatch Observability addons, Load Balancer Ingress Controller and External DNS Controller.
     - Apart from the all the other addons and Load Balancer Controller which are created in the kube-system namespace, the External DNS Controller is created in the default namespace.
     - From the above list of addons and agents, each or all of those resources can be individually selected to be installed or abstained to be created based on the boolean value supplied to their respective arguments in the root module.
     - Based on the addons/agents selected to be installed, it will also selectively create the right IAM permissions suitable to run those appropriately. 
         
-    For the AWS VPC, based on the count of the number of subnets selected by the user in the root module, it can conditonally, automatically create those subnets along with their IP addresses using the cidrsubnet() based on the VPC CIDR block selected. 
     -    However, if the user needs to use the subnet IP addresses of their own choice, then those subnet IP addresses can be manually configured in the variables/*.tfvars file in the root module by supplying a value of "false" to the 'auto_create_subnet_addresses' argument in the root module.
     -    These subnets are then created in the automatically selected and shuffled Availability Zones. 
-    This module also creates an Ingress Class with the controller type of Application Load Balancer. 

## Requirements

-    In this module, both the EBS and EFS driver addons depend on the public and private EKS node groups hence it expects both these node groups to be created, only then both these above mentioned addons will be created.

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
| public_subnet_cidr_addresses                         | list(string)       | To be entered manually if auto_create_subnet_addresses is set to false.                                                                      |
| private_subnet_count                                 | number       | Number of private subnets to create.                                                                                                         |
| private_subnet_cidr_addresses                        | list(string)       | To be entered manually if auto_create_subnet_addresses is set to false.                                                                      |
| cluster_public_security_groups_name                  | string       | Public Security Groups name.                                                                                                                 |
| cluster_public_security_groups_desc                  | string       | Public Security Groups description.                                                                                                          |
| ssh_access_ips                                       | string       | IP address CIDR block defined in Inboundaddresses to the public security group.                                                              |
| cluster_efs_security_group_name                      | string       | EFS security group name of your cluster.                                                                                                     |
| cluster_efs_security_group_desc                      | string       | EFS security group description of your cluster.                                                                                              |
|                                                      |              |                                                                                                                                              |
| EKS Cluster related Inputs:                          |              |                                                                                                                                              |
| cluster_name                                         | string       | EKS Cluster name.                                                                                                                            |
| eks_cluster_version                                  | string       | EKS Cluster version to be created.                                                                                                           |
|                                                      |              |                                                                                                                                              |
| create_cloudwatch_observability_and_fluentbit_agents | boolean      | A value of 'true' will create the CloudWatch and Fluentbit Agents, and a value of 'false' will abstain from creating them.                   |
| create_ebs_csi_driver                                | boolean      | A value of 'true' will create the EBS CSI Driver, and a value of 'false' will abstain from creating it.                                      |
| create_efs_csi_driver                                | boolean      | A value of 'true' will create the EFS CSI Driver, and a value of 'false' will abstain from creating it.                                      |
| create_ingress_lb_controller                         | boolean      | A value of 'true' will create the Ingress Load Balancer Controller, and a value of 'false' will abstain from creating it.                    |
| create_external_dns_controller                       | boolean      | A value of 'true' will create the External DNS Controller, and a value of 'false' will abstain from creating it.                             |
|                                                      |              |                                                                                                                                              |
| cluster_service_ipv4_cidr                            | string       | The CIDR block to assign Kubernetes pod and service IP addresses from.                                                                       |
| cluster_endpoint_private_access                      | boolean      | A value of 'true' will enable the Amazon EKS private API server endpoint and a value of 'false' will disable it.                             |
| cluster_endpoint_public_access                       | boolean      | A value of 'true' will enable the Amazon EKS public API server endpoint and a value of 'false' will disable it.                              |
| cluster_endpoint_public_access_cidrs                 | list(string) | Indicates which list of CIDR blocks can access EKS public API aerver endpoint when enabled. EKS defaults this to "0.0.0.0/0".                |
|                                                      |              |                                                                                                                                              |
| EKS nodegroup related inputs:                        |              |                                                                                                                                              |
| eks_public_nodegroup_name                            | string       | Name assigned to your EKS public nodegroup.                                                                                                  |
| public_nodegroup_ami_type                            | string       | AMI type of the nodegroup worker node instances.                                                                                             |
| public_nodegroup_capacity_type                       | string       | Type of capacity of the Node group instances. Valid values - ON_DEMAND, SPOT.                                                                |
| public_nodegroup_disk_size                           | number       | Disk size in GiB for worker nodes. Defaults to 50 for Windows and 20 for all other node groups.                                              |
| public_nodegroup_instance_types                      | string       | List of instance types associated wih the Node groups Defaults to "t3.medium".                                                               |
|                                                      |              |                                                                                                                                              |
| public_nodegroup_desired_size                        | number       | Desired number of worker nodes.                                                                                                              |
| public_nodegroup_max_size                            | number       | Maximum number of worker nodes.                                                                                                              |
| public_nodegroup_mix_size                            | number       | Minimum number of worker nodes.                                                                                                              |
| public_node_max_unavail_pctage                       | number       | Desired max percentage of unavailable worker nodes during group update.                                                                      |

## Resources

| Name                                               | Type        | Description                                                                                                                                                                                        |
| :------------------------------------------------- | :---------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| VPC Resources:                                     |             |                                                                                                                                                                                                    |
| aws_vpc.my_eks_vpc                                 | resource    | AWS VPC.                                                                                                                                                                                           |
| aws_availability_zones.available                    | data source | Data source to get all the possible AZ s from an AWS region.                                                                                                                                       |
| aws_subnet.my_public_subnets                      | resource    | Public Subnets of the VPC.                                                                                                                                                                         |
| aws_route_table.public_route_table                 | resource    | Public Route Table.                                                                                                                                                                                |
| aws_internet_gateway.my_igw                        | resource    | Internet Gateway.                                                                                                                                                                                  |
| aws_subnet.my_private_subnets                     | resource    | Private Subnets.                                                                                                                                                                                   |
| aws_default_route_tabledefault_private_route_table | resource    | Default Private Route Table.                                                                                                                                                                       |
| aws_route_table.private_route_table                | resource    | Private Route Table.                                                                                                                                                                               |
| aws_eip.nat_gw_eip                                 | resource    | NAT Gateway Elastic IP.                                                                                                                                                                            |
| aws_nat_gateway.my_nat_gateway                     | resource    | NAT Gateway.                                                                                                                                                                                       |
| aws_security_group.cluster_sg                      | resource    | AWS EKS Cluster Security Group.                                                                                                                                                                    |
|                                                    |             |                                                                                                                                                                                                    |
| EKS Cluster Resources:                             |             |                                                                                                                                                                                                    |
| aws_iam_role.eks_master_role                       | resource    | AWS EKS Master IAM role with AmazonEKSClusterPolicy and AmazonEKSVPCResourceController IAM Policies attached.                                                                                      |
| aws_iam_role.eks_nodegroup_role                    | resource    | AWS EKS Node Group IAM role with AmazonEKSWorkerNodePolicy, AmazonEKS_CNI_Policy, AmazonEC2ContainerRegistryReadOnly, AmazonEBSCSIDriverPolicy and AmazonEFSCSIDriverPolicy IAM Policies attached. |
| aws_iam_openid_connect_provider.oidc_provider      | resource    | AWS IAM OpenId Connect Provider.                                                                                                                                                                   |
| http.lbc_iam_policy                                | data source | Load Balancer IAM policy.                                                                                                                                                                          |
| aws_iam_role.lbc_iam_role                          | resource    | Load Balancer IAM role with an action of AssumeRolewithWebIdentity for the AWS IAM OIDC Provider Principal.                                                                                        |
| aws_eks_cluster.my_eks_cluster                     | resource    | AWS EKS cluster.                                                                                                                                                                                   |
| aws_eks_node_group.my_eks_public_nodegroup         | resource    | Public EKS Node Group.                                                                                                                                                                             |
| aws_eks_node_group.my_eks_private_nodegroup        | resource    | Private Node Group.                                                                                                                                                                                |
| aws_eks_addon.aws_ebs_csi_driver                   | resource    | EKS Addon for EBS CSI Driver.                                                                                                                                                                      |
| aws_eks_addon.aws_efs_csi_driver                   | resource    | EKS Addon for EFS CSI Driver.                                                                                                                                                                      |
| helm_release.lb_controller                         | resource    | Helm release to install the Load Balancer Controller.                                                                                                                                              |
| aws_iam_role.ext_dns_iam_role                      | resource    | External DNS Role with an IAM policy of ChangeResourceRecordSets, ListHostedZones & ListResourceRecordSets. permissions                                                                            |
| helm_release.external_dns                          | resource    | Helm release to install the External DNS controller.                                                                                                                                               |

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
| EKS IRSA related Outputs:                        |              |                                                                                                                                                                 |
| aws_iam_openid_connect_provider_arn              | string       | OpenId Connect Provider ARN.                                                                                                                                    |
| aws_iam_openid_connect_provider_extract_from_arn | string       | Extract of the OIDC Id part from the OpenId Connect Provider ARN.                                                                                               |
|                                                  |              |                                                                                                                                                                 |
| EKS-EBS-CSI-Addon related Outputs:                |              |                                                                                                                                                                 |
| ebs_eks_addon_arn                                | string       | EBS CSI driver ARN.                                                                                                                                             |
| ebs_eks_addon_id                                 | string       | EBS CSI driver Id.                                                                                                                                              |
|                                                  |              |                                                                                                                                                                 |
| EKS-EFS-CSI-Addon related Outputs:               |              |                                                                                                                                                                 |
| efs_eks_addon_arn                                | string       | EFS CSI driver ARN.                                                                                                                                             |
| efs_eks_addon_id                                 | string       | EFS CSI driver Id.                                                                                                                                              |