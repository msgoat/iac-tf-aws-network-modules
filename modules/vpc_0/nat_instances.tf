# retrieve latest AMI for NAT instances provided by AWS

locals {
  # make sure that NAT instances are only created when current NAT strategy is NAT_INSTANCE
  number_of_nat_instances = var.nat_strategy == "NAT_INSTANCE" ? length(data.aws_availability_zones.zones.names) : 0
}

# create a NAT instance for each AZ
resource aws_instance nats {
  count = local.number_of_nat_instances
  ami = data.aws_ami.nat.id
  instance_type = var.nat_instance_type
  subnet_id = aws_subnet.public_web_subnets[count.index].id
  vpc_security_group_ids = [aws_security_group.nat.id]
  tags = merge({
    "Name" = "ec2-${data.aws_availability_zones.zones.names[count.index]}-${var.network_name}-nat"
  }, local.module_common_tags)
}

# retrieve latest AMI for NAT instances
data aws_ami nat {
  most_recent = true
  owners = ["137112412989"]  # Amazon EC2 AMI Account ID

  filter {
    name = "name"
    values = ["amzn-ami-vpc-nat-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# create common security group for all NAT instances
# - to keep things simple the security group is created even if no NAT instances will be allocated
resource aws_security_group nat {
  name = "sec-${data.aws_region.current.name}-${var.network_name}-nat"
  description = "Security group for all NAT instances in VPC"
  vpc_id = aws_vpc.vpc.id
  tags = merge({
    "Name" = "sg-${data.aws_region.current.name}-${var.network_name}-nat"
  }, local.module_common_tags)
}

resource aws_security_group_rule nat_http_ingress {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  security_group_id = aws_security_group.nat.id
  cidr_blocks = [aws_vpc.vpc.cidr_block]
  description = "Allow inbound HTTP traffic from servers in the private subnet"
}

resource aws_security_group_rule nat_https_ingress {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  security_group_id = aws_security_group.nat.id
  cidr_blocks = [aws_vpc.vpc.cidr_block]
  description = "Allow inbound HTTPS traffic from servers in the private subnet"
}

resource aws_security_group_rule nat_http_egress {
  type = "egress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  security_group_id = aws_security_group.nat.id
  cidr_blocks = ["0.0.0.0/0"]
  description = "Allow outbound HTTP traffic from NAT instances to the internet"
}

resource aws_security_group_rule nat_https_egress {
  type = "egress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  security_group_id = aws_security_group.nat.id
  cidr_blocks = ["0.0.0.0/0"]
  description = "Allow outbound HTTPS traffic from NAT instances to the internet"
}

# create a route that routes all internet-bound traffic from private subnets to the NAT instance in the same AZ
resource aws_route nat {
  count = local.number_of_nat_instances
  route_table_id = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  instance_id = aws_instance.nats[count.index].id
}
