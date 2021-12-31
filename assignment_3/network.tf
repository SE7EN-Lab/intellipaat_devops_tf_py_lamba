# VPC definition
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = var.vpc_tag
  }
}

# Subnet definition
resource "aws_subnet" "subnet_public_one" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.public_subnet_1
  map_public_ip_on_launch = true
  availability_zone       = var.az_1
  tags = {
    Name = var.public_snet1_tag
  }
}

resource "aws_subnet" "subnet_public_two" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.public_subnet_2
  map_public_ip_on_launch = true
  availability_zone       = var.az_2
  tags = {
    Name = var.public_snet2_tag
  }
}

resource "aws_subnet" "subnet_private_one" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.private_subnet_1
  map_public_ip_on_launch = false
  availability_zone       = var.az_1
  tags = {
    Name = var.private_snet1_tag
  }
}

resource "aws_subnet" "subnet_private_two" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.private_subnet_2
  map_public_ip_on_launch = false
  availability_zone       = var.az_1
  tags = {
    Name = var.private_snet2_tag
  }
}

# Internet Gateway definition
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = var.igw_main
  }
}

# Custom Route table definition
resource "aws_route_table" "public_crt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = var.crt_public
  }
}

# CRT and Subnets asssociation
resource "aws_route_table_association" "crt_public_subnet_one" {
  subnet_id      = aws_subnet.subnet_public_one.id
  route_table_id = aws_route_table.public_crt.id
}
resource "aws_route_table_association" "crt_public_subnet_two" {
  subnet_id      = aws_subnet.subnet_public_two.id
  route_table_id = aws_route_table.public_crt.id
}

# NAT Gateway defintion
resource "aws_eip" "eip_one" {
  instance = aws_instance.bastion_host.id
  vpc      = true

}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip_one.id
  subnet_id     = aws_subnet.subnet_public_one.id

  tags = {
    Name = var.gw_nat
  }

  depends_on = [aws_internet_gateway.main_igw]

}

output "elastic_ip" {

  value = aws_eip.eip_one

}