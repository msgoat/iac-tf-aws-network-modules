# iac-tf-aws-network-modules

Terraform multi-module to set up network resources on AWS.

Provides the following modules:

| Module Name                                      | Module Source         | Description                                                                                                                       |
|--------------------------------------------------|-----------------------|-----------------------------------------------------------------------------------------------------------------------------------|
| [vpc](modules/vpc/README.md)                     | modules/vpc           | Creates a VPC spanning the given number of availability zones with the given stack of subnets                                     | 
| [vpc-blueprint](modules/vpc-blueprint/README.md) | modules/vpc-blueprint | Creates a VPC spanning the given number of availability zones a default stack of subnets according to the VPC Reference Blueprint | 

