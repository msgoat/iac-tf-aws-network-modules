output vpc_id {
  description = "Unique identifier of the newly created VPC network."
  value = aws_vpc.vpc.id
}

output vpc_name {
  description = "Fully qualified name of the newly created VPC network."
  value = aws_vpc.vpc.tags["Name"]
}

output bastion_security_group_name {
  description = "Name of the security group applied to all bastion instances."
  value = local.bastion_enabled ? aws_security_group.bastion[0].name : ""
}

output bastion_security_group_id {
  description = "Unique identifier of the security group applied to all bastion instances."
  value = local.bastion_enabled ? aws_security_group.bastion[0].id : ""
}

output public_subnet_ids {
  description = "Unique identifiers of all public subnets"
  value = aws_subnet.public_web_subnets.*.id
}

output private_subnet_ids {
  description = "Unique identifiers of all private subnets"
  value = concat(aws_subnet.private_app_subnets.*.id, aws_subnet.private_data_subnets.*.id)
}

output web_subnet_ids {
  description = "Unique identifiers of all web subnets"
  value = aws_subnet.public_web_subnets.*.id
}

output app_subnet_ids {
  description = "Unique identifiers of all application subnets"
  value = aws_subnet.private_app_subnets.*.id
}

output data_subnet_ids {
  description = "Unique identifiers of all datastore subnets"
  value = aws_subnet.private_data_subnets.*.id
}
