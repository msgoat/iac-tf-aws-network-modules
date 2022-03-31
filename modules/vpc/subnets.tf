locals {
  // calculate number of availability zones to span
  number_of_zones_to_span = var.zones_to_span == 0 ? length(data.aws_availability_zones.zones.names) : var.zones_to_span
  // retrieve names of all availability zones to span
  names_of_zones_to_span = slice(data.aws_availability_zones.zones.names, 0, local.number_of_zones_to_span)
  // convert given list of subnets to map
  given_subnet_names = [ for sn in var.subnets : sn.subnet_name ]
  given_subnets_by_name = zipmap(local.given_subnet_names, var.subnets)
  // build product of availability zones to span and given subnets to repeat given subnets in each spanned zone
  subnets_per_zone = [ for pair in setproduct(local.names_of_zones_to_span, local.given_subnet_names) : {
    subnet_name = "sn-${pair[0]}-${var.solution_fqn}-${var.network_name}-${pair[1]}"
    given_subnet_name = pair[1]
    zone_name = pair[0]
  } ]
  // build map with subnet name / subnet index entries
  subnet_names = [ for sn in local.subnets_per_zone : sn.subnet_name ]
  subnet_indexes = range(0, length(local.subnet_names))
  subnet_index_by_name = zipmap(local.subnet_names, local.subnet_indexes)
  // build map of subnet template key / values with stable keys
  subnet_template_keys = [ for sn in local.subnets_per_zone : "${sn.zone_name}-${sn.given_subnet_name}" ]
  subnet_template_values = [ for spz in local.subnets_per_zone : {
    subnet_name = spz.subnet_name
    given_subnet_name = spz.given_subnet_name
    zone_name = spz.zone_name
    accessibility = local.given_subnets_by_name[spz.given_subnet_name].accessibility
    newbits = local.given_subnets_by_name[spz.given_subnet_name].newbits
    tags = local.given_subnets_by_name[spz.given_subnet_name].tags
    subnet_number = local.subnet_index_by_name[spz.subnet_name] + 1
    cidr_block = cidrsubnet(var.network_cidr, local.given_subnets_by_name[spz.given_subnet_name].newbits, local.subnet_index_by_name[spz.subnet_name] + 1)
  } ]
  subnet_templates = zipmap(local.subnet_template_keys, local.subnet_template_values)
}

// create a subnet based on each subnet template
resource aws_subnet subnets {
  for_each = local.subnet_templates
  vpc_id = aws_vpc.vpc.id
  availability_zone = each.value.zone_name
  map_public_ip_on_launch = each.value.accessibility == "public" ? true : false
  cidr_block = cidrsubnet(var.network_cidr, each.value.newbits, each.value.subnet_number)
  tags = merge({
    Name = each.value.subnet_name
    TemplateName = each.value.given_subnet_name
    Accessibility = each.value.accessibility
  }, each.value.tags, local.module_common_tags)
}
