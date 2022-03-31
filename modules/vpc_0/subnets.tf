locals {
  zones_to_span = var.zones_to_span == 0 ? length(data.aws_availability_zones.zones.names) : var.zones_to_span
  zone_names_to_span = slice(data.aws_availability_zones.zones.names, 0, zones_to_span)
}

# create a public web subnet in each availability zone
resource aws_subnet public_web_subnets {
  count = length(data.aws_availability_zones.zones.names)
  vpc_id = aws_vpc.vpc.id
  cidr_block = local.public_web_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.zones.names[count.index]
  map_public_ip_on_launch = true
  tags = merge({Name = "${local.subnet_name_prefixes[count.index]}-web"}, local.module_common_tags)
}

# create a private application subnet in each availability zone
resource aws_subnet private_app_subnets {
  count = length(data.aws_availability_zones.zones.names)
  vpc_id = aws_vpc.vpc.id
  cidr_block = local.private_app_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.zones.names[count.index]
  map_public_ip_on_launch = false
  tags = merge({Name = "${local.subnet_name_prefixes[count.index]}-app"}, local.module_common_tags)
}

# create a private datastore subnet in each availability zone
resource aws_subnet private_data_subnets {
  count = length(data.aws_availability_zones.zones.names)
  vpc_id = aws_vpc.vpc.id
  cidr_block = local.private_data_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.zones.names[count.index]
  map_public_ip_on_launch = false
  tags = merge({Name = "${local.subnet_name_prefixes[count.index]}-data"}, local.module_common_tags)
}
