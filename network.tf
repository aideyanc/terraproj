# Create dev environment VPC for Online4Baby
resource "aws_vpc" "o4bproject" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "AmpDevO4b-vpc"
    Environment = "dev"
  }
}

# Create private subnet
resource "aws_subnet" "o4bproject-private" {
  count             = var.item_count
  vpc_id            = aws_vpc.o4bproject.id
  availability_zone = var.private_subnet_availability_zone[count.index]
  cidr_block        = var.private_subnet_cidr_block[count.index]

  tags = {
    Name        = "AmpDevO4b-private-subnet-${count.index}"
    Environment = "dev"
  }
}

# Create public subnet
resource "aws_subnet" "o4bproject-public" {
  count             = var.item_count
  vpc_id            = aws_vpc.o4bproject.id
  availability_zone = var.public_subnet_availability_zone[count.index]
  cidr_block        = var.public_subnet_cidr_block[count.index]

  tags = {
    Name        = "AmpDevO4b-public-subnet-${count.index}"
    Environment = "dev"
  }
}

# Create route tables for the subnet
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.o4bproject.id

  tags = {
    Name        = "AmpDevO4b-public-route-table"
    Environment = "dev"
  }
}

# Create route table for the private subnet 
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.o4bproject.id

  tags = {
    Name        = "AmpDevO4b-private-route-table"
    Environment = "dev"
  }
}

# Associate newly created route tables to the subnets
resource "aws_route_table_association" "public-route-association" {
  count          = var.item_count
  route_table_id = aws_route_table.public-route-table.id
  subnet_id      = aws_subnet.o4bproject-public[count.index].id
}

resource "aws_route_table_association" "private-route-association" {
  count          = var.item_count
  route_table_id = aws_route_table.private-route-table.id
  subnet_id      = aws_subnet.o4bproject-private[count.index].id
}

# Create internet gateway for the public subnet
resource "aws_internet_gateway" "o4bproject-igw" {
  vpc_id = aws_vpc.o4bproject.id

  tags = {
    Name        = "AmpDevO4b-igw"
    Environment = "dev"
  }
}

# Route public subnet traffic through the internet gateway
resource "aws_route" "public-internet-gateway-route" {
  route_table_id         = aws_route_table.public-route-table.id
  gateway_id             = aws_internet_gateway.o4bproject-igw.id
  destination_cidr_block = "0.0.0.0/0"
}

/*
# Create DHCP options in our VPC
resource "aws_vpc_dhcp_options" "o4bproject-dhcp" {
  domain_name         = "${var.aws_region}.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]
  tags = {
    Name        = "o4bproject-dhcp"
    Environment = "dev"
  }
}

# Assign DHCP options to our VPC
resource "aws_vpc_dhcp_options_association" "o4bproject-dhcp-association" {
  vpc_id          = aws_vpc.o4bproject.id
  dhcp_options_id = aws_vpc_dhcp_options.o4bproject-dhcp.id
}
*/

# Create elastic ip
resource "aws_eip" "o4bproject-eip-nat-gateway" {
  count                     = var.item_count
  vpc                       = true
  associate_with_private_ip = "172.19.1.167"
  depends_on                = [aws_internet_gateway.o4bproject-igw]

  tags = {
    Name        = "AmpDevO4b-eip"
    Environment = "dev"
  }
}

# Create NAT gateway
resource "aws_nat_gateway" "o4bproject-nat-gateway" {
  allocation_id = aws_eip.o4bproject-eip-nat-gateway[count.index].id
  count         = var.item_count
  subnet_id     = aws_subnet.o4bproject-public[count.index].id
  depends_on    = [aws_eip.o4bproject-eip-nat-gateway]

  tags = {
    Name        = "AmpDevO4b-nat-gw"
    Environment = "dev"
  }
}

# Route private subnet traffic through NAT gateway
resource "aws_route" "o4bproject-nat-gateway-route" {
  count                  = var.item_count
  route_table_id         = aws_route_table.private-route-table.id
  nat_gateway_id         = aws_nat_gateway.o4bproject-nat-gateway[count.index].id
  destination_cidr_block = "0.0.0.0/0"
}
