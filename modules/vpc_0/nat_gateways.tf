# nat_gateways.tf

locals {
  # make sure that NAT gateways are only created when current NAT strategy is NAT_GATEWAY
  number_of_nat_gateways = var.nat_strategy == "NAT_GATEWAY" ? length(data.aws_availability_zones.zones.names) : 0
  nat_gateway_names = [for zone in data.aws_availability_zones.zones.names : "nat-${zone}-${var.solution_fqn}-${var.network_name}"]
  eip_names = [for zone in data.aws_availability_zones.zones.names : "eip-${zone}-${var.solution_fqn}-${var.network_name}-nat"]
}

# create NAT gateway with Elastic IP
resource aws_nat_gateway nat {
  count = local.number_of_nat_gateways
  allocation_id = aws_eip.nat[count.index].id
  subnet_id = aws_subnet.public_web_subnets[count.index].id
  tags = merge({
    Name = local.nat_gateway_names[count.index]
  }, local.module_common_tags)
}

# create Elastic IP (EIP) to assign to NAT gateway
resource aws_eip nat {
  count = local.number_of_nat_gateways
  vpc = true
  tags = merge({
    Name = local.eip_names[count.index]
  }, local.module_common_tags)
}

# create a route that routes all internet-bound traffic from private subnets to the NAT gateway in the same AZ
resource aws_route ngw {
  count = local.number_of_nat_gateways
  route_table_id = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat[count.index].id
}
