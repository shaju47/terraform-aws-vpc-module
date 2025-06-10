provider "aws" {
  region = "us-east-1"
}

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
