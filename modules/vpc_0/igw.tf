# igw.tf
# Creates an Internet Gateway plus a route referring to it

# --- Internet Gateway -------------------------------------------------------

locals {
  igw_name = "igw-${var.region_name}-${var.solution_fqn}-${lower(var.network_name)}"
}
# create an internet gateway to give our subnet access to the outside world
resource aws_internet_gateway igw {
  vpc_id = aws_vpc.vpc.id
  tags = merge({Name = local.igw_name}, local.module_common_tags)
}

# create a route that routes all internet-bound traffic from public subnets to the internet gateway
resource aws_route igw {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}
