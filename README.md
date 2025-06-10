
# Terraform AWS VPC Module

##  Overview

This Terraform module provisions a customizable VPC in AWS with:

- Public and private subnets across multiple availability zones
- Internet Gateway and NAT Gateway
- Route tables for each subnet type

##  Module Inputs

| Name                  | Type           | Description                         |
|-----------------------|----------------|-------------------------------------|
| `vpc_name`            | `string`       | Name for the VPC                    |
| `cidr_block`          | `string`       | VPC CIDR block                      |
| `enable_dns_hostnames`| `bool`         | Enable DNS hostnames in the VPC     |
| `public_subnet_cidrs` | `list(string)` | CIDRs for public subnets            |
| `private_subnet_cidrs`| `list(string)` | CIDRs for private subnets           |
| `availability_zones`  | `list(string)` | List of AZs                         |
| `az_index_map`        | `map(number)`  | Mapping AZ name -> index in CIDR list|

##  Outputs

- `vpc_id`: The ID of the created VPC
- `public_subnet_ids`: List of public subnet IDs
- `private_subnet_ids`: List of private subnet IDs

##  Usage Example

```hcl
module "vpc" {
  source               = "../../modules/vpc"
  vpc_name             = "demo-vpc"
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  availability_zones     = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs    = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs   = ["10.0.3.0/24", "10.0.4.0/24"]
  az_index_map           = { "us-east-1a" = 0, "us-east-1b" = 1 }
}
