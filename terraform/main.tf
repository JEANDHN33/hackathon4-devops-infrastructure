# Data source pour AMI ARM64 (Amazon Linux 2023)
data "aws_ami" "amazon_linux_arm64" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

# VPC principal pour Hackathon 4
resource "aws_vpc" "hackathon4_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.environment}-vpc"
    Type = "main-network"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "hackathon4_igw" {
  vpc_id = aws_vpc.hackathon4_vpc.id

  tags = {
    Name = "${var.environment}-internet-gateway"
  }
}

# Subnets publics pour chaque AZ
resource "aws_subnet" "public_subnets" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.hackathon4_vpc.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-public-subnet-${count.index + 1}"
    Type = "public"
    AZ   = var.availability_zones[count.index]
  }
}

# Table de routage publique
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.hackathon4_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.hackathon4_igw.id
  }

  tags = {
    Name = "${var.environment}-public-route-table"
  }
}

# Associations subnet-route table
resource "aws_route_table_association" "public_subnet_associations" {
  count = length(aws_subnet.public_subnets)

  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}
