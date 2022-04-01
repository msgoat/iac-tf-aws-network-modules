terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

module vpc_public_private_nat_single {
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
  network_name = "vpcpubprivnatsingle"
  network_cidr = "10.0.0.0/16"
  inbound_traffic_cidrs = [ "0.0.0.0/0" ]
  nat_strategy = "NAT_GATEWAY_SINGLE"
  zones_to_span = 2
  subnets = [
    {
      subnet_name = "apps"
      accessibility = "private"
      newbits = 4
      tags = {}
    },
    {
      subnet_name = "web"
      accessibility = "public"
      newbits = 8
      tags = {}
    }
  ]
}

output subnets {
  value = module.vpc_public_private_nat_single.subnets
}

output debug {
  value = module.vpc_public_private_nat_single.debug
}