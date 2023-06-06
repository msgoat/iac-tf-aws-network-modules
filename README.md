# iac-tf-aws-network-modules

> __@deprecated__ please use git repo [iac-tf-aws-cloudtrain-modules](https://github.com/msgoat/iac-tf-az-cloudtrain-modules) instead!

Terraform multi-module to set up network resources on AWS.

Provides the following modules:

| Module Name                                      | Module Source         | Description                                                                                                                       |
|--------------------------------------------------|-----------------------|-----------------------------------------------------------------------------------------------------------------------------------|
| [vpc](modules/vpc/README.md)                     | modules/vpc           | Creates a VPC spanning the given number of availability zones with the given stack of subnets                                     | 
| [vpc-blueprint](modules/vpc-blueprint/README.md) | modules/vpc-blueprint | Creates a VPC spanning the given number of availability zones a default stack of subnets according to the VPC Reference Blueprint | 

