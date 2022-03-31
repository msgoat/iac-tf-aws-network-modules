# route_tables.tf

# route all outbound internet traffic from public subnets through the Internet Gateway
resource aws_route_table public {
  vpc_id = aws_vpc.vpc.id
  tags = merge({
    "Name" = "rtb-${data.aws_region.current.name}-${var.network_name}-igw"
  }, local.module_common_tags)
}

resource aws_route_table_association public_web {
  count = length(aws_subnet.public_web_subnets)
  subnet_id = aws_subnet.public_web_subnets[count.index].id
  route_table_id = aws_route_table.public.id
}

resource aws_route_table private {
  count = length(data.aws_availability_zones.zones.names)
  vpc_id = aws_vpc.vpc.id
  tags = merge({
    "Name" = "rtb-${data.aws_availability_zones.zones.names[count.index]}-${var.network_name}-ngw"
  }, local.module_common_tags)
}

resource aws_route_table_association private_app {
  count = length(data.aws_availability_zones.zones.names)
  subnet_id = aws_subnet.private_app_subnets[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource aws_route_table_association private_data {
  count = length(data.aws_availability_zones.zones.names)
  subnet_id = aws_subnet.private_data_subnets[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

