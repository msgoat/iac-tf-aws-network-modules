terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

module "vpc_blueprint" {
  source         = "../..//modules/vpc-blueprint"
  region_name    = "eu-west-1"
  solution_name  = "iactst2022"
  solution_stage = "dev"
  solution_fqn   = "iactst2022-dev"
  common_tags = {
    Organization = "msg systems ag"
    Department   = "AT2"
    ManagedBy    = "Terraform"
    PartOf       = "CloudTrain"
  }
  network_name          = "vpcblueprint"
  network_cidr          = "10.0.0.0/16"
  inbound_traffic_cidrs = ["0.0.0.0/0"]
  nat_strategy          = "NAT_GATEWAY_SINGLE"
}
