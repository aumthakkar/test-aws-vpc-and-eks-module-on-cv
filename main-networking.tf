
# === vpc networking related /main.tf ===

resource "random_integer" "vpc_random_int" {
  max = 100
  min = 1
}

resource "aws_vpc" "my_eks_vpc" {
  cidr_block = var.vpc_cidr

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.name_prefix}-eks-vpc-${random_integer.vpc_random_int.result}"
  }

  lifecycle {
    create_before_destroy = true
  }
}


data "aws_availability_zones" "available" {
  state = "available"
}


resource "random_shuffle" "az_shuffle" {
  input = data.aws_availability_zones.available.names

  result_count = 10
}


resource "aws_subnet" "my_public_subnets" {
  count = var.public_subnet_count

  vpc_id                  = aws_vpc.my_eks_vpc.id
  map_public_ip_on_launch = true

  cidr_block        = local.public_subnet_cidr_block[count.index]
  availability_zone = random_shuffle.az_shuffle.result[count.index]

  tags = {
    Name = "${var.name_prefix}-public-subnet-${count.index + 1}"
  }
}


resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_eks_vpc.id

  tags = {
    Name = "${var.name_prefix}-public-route-table"
  }
}


resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_eks_vpc.id

  tags = {
    Name = "${var.name_prefix}-igw"
  }
}


resource "aws_route_table_association" "public_rt_assoc" {
  count = var.public_subnet_count

  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.my_public_subnets[count.index].id
}


resource "aws_route" "public_route" {
  route_table_id = aws_route_table.public_route_table.id

  gateway_id             = aws_internet_gateway.my_igw.id
  destination_cidr_block = "0.0.0.0/0"

}

resource "aws_subnet" "my_private_subnets" {
  count = var.private_subnet_count

  vpc_id = aws_vpc.my_eks_vpc.id

  cidr_block        = local.private_subnet_cidr_block[count.index]
  availability_zone = random_shuffle.az_shuffle.result[count.index]

  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name_prefix}-private-subnet-${count.index + 1}"
  }
}


resource "aws_default_route_table" "default_private_route_table" {
  default_route_table_id = aws_vpc.my_eks_vpc.default_route_table_id

  tags = {
    Name = "${var.name_prefix}-main-route-table-(private)"
  }
}


resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_eks_vpc.id

  tags = {
    Name = "${var.name_prefix}-private-route-table"
  }
}

resource "aws_eip" "nat_gw_eip" {
  domain = "vpc"

  tags = {
    Name = "${var.name_prefix}-nat-gw-eip"
  }

  depends_on = [aws_internet_gateway.my_igw]
}


resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.nat_gw_eip.id
  subnet_id     = aws_subnet.my_public_subnets[0].id

  tags = {
    Name = "${var.name_prefix}-nat-gateway"
  }

  depends_on = [aws_internet_gateway.my_igw]
}


resource "aws_route_table_association" "private_rt_assoc" {
  count = var.private_subnet_count

  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.my_private_subnets[count.index].id
}


resource "aws_route" "private_route" {
  route_table_id = aws_route_table.private_route_table.id

  gateway_id             = aws_nat_gateway.my_nat_gateway.id
  destination_cidr_block = "0.0.0.0/0"

}


resource "aws_security_group" "cluster_sg" {
  for_each = local.cluster_security_groups

  vpc_id = aws_vpc.my_eks_vpc.id

  name        = each.value.name
  description = each.value.description
  tags        = each.value.tags

  dynamic "ingress" {
    for_each = each.value.ingress

    content {
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = [ingress.value.cidr_blocks]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}
