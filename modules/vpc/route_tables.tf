locals {
  public_subnet_ids = [ for sn in aws_subnet.subnets : sn.id if sn.tags["Accessibility"] == "public"]
  private_subnet_ids = [ for sn in aws_subnet.subnets : sn.id if sn.tags["Accessibility"] == "private"]
  names_of_zones_with_private_subnets = distinct([ for sn in aws_subnet.subnets : sn.availability_zone if sn.tags["Accessibility"] == "private"])
  private_subnets_by_zone_keys = distinct([ for sn in aws_subnet.subnets : sn.availability_zone if sn.tags["Accessibility"] == "private"])
  private_subnets_by_zone_values = [ for sn in aws_subnet.subnets : {

  } if sn.tags["Accessibility"] == "private"]
}

# create a common custom gateway route table for all public subnets in all availability zones
resource aws_route_table public {
  vpc_id = aws_vpc.vpc.id
  tags = merge({
    Name = "rtb-${data.aws_region.current.name}-${var.solution_fqn}-${var.network_name}-public"
  }, local.module_common_tags)
}

# associate this custom gateway route table with all public subnets in all availability zones
resource aws_route_table_association public {
  count = length(local.public_subnet_ids)
  subnet_id = local.public_subnet_ids[count.index]
  route_table_id = aws_route_table.public.id
}

# create a common custom gateway route table for all private subnets in one availability zone
resource aws_route_table private {
  count = length(local.names_of_zones_with_private_subnets)
  vpc_id = aws_vpc.vpc.id
  tags = merge({
    Name = "rtb-${local.names_of_zones_with_private_subnets[count.index]}-${var.solution_fqn}-${var.network_name}-private"
  }, local.module_common_tags)
}
