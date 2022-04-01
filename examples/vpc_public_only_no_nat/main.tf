terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

module vpc_public_only_no_nat {
  source = "../../modules/vpc"
  region_name = "eu-west-1"
  solution_name = "iactst2022"
  solution_stage = "dev"
  solution_fqn = "iactst2022-dev"
  common_tags = {
    Organization = "msg systems ag"
    Department = "AT2"
    ManagedBy = "Terraform"
    PartOf = "CloudTrain"
  }
  network_name = "vpcpubonlynonat"
  network_cidr = "10.0.0.0/16"
  inbound_traffic_cidrs = [ "0.0.0.0/0" ]
  nat_strategy = "NAT_NONE"
  zones_to_span = 3
  subnets = [
    {
      subnet_name = "web"
      accessibility = "public"
      newbits = 8
      tags = {}
    }
  ]
}

output subnets {
  value = module.vpc_public_only_no_nat.subnets
}

output debug {
  value = module.vpc_public_only_no_nat.debug
}