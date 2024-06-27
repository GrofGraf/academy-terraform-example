resource "aws_vpc" "this" {
  cidr_block = "172.22.0.0/16"

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Stage = var.stage_slug
  }
}

# Fetch availability zones in the current region
data "aws_availability_zones" "available" {}

# Create public subnets for each AZ
resource "aws_subnet" "public" {
  count = 2

  cidr_block              = cidrsubnet(aws_vpc.this.cidr_block, 8, 2 + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.this.id
  map_public_ip_on_launch = true
}

# IGW for the public subnet (attaches public IP)
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

# route the public subnet traffic through the IGW
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.this.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}
