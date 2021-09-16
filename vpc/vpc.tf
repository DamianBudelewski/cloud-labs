locals {
  network_acls = {
    default_inbound = [
      {
        rule_number = 900
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      }
    ]
    default_outbound = [
      {
        rule_number = 900
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      }
    ]
    public_inbound = [
      {
        rule_number = 110
        rule_action = "allow"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0" 
      },
      {
        rule_number = 120
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = var.vpc_cidr
      },
      {
        rule_number = 130
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = var.vpc_cidr
      }
    ]
    public_outbound = [
      {
        rule_number = 110
        rule_action = "allow"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0" 
      },
      {
        rule_number = 120
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0" 
      }
    ]
    private_inbound = [
      {
        rule_number = 110
        rule_action = "allow"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = var.vpc_cidr
      }
    ]
    private_outbound = [
      {
        rule_number = 110
        rule_action = "allow"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = var.vpc_cidr
      },
      {
        rule_number = 120
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0" 
      }
    ]
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "mastering-aws-vpc"
  cidr = var.vpc_cidr

  azs = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  public_dedicated_network_acl   = true
  public_inbound_acl_rules       = concat(local.network_acls["public_inbound"], local.network_acls["default_inbound"])
  public_outbound_acl_rules      = concat(local.network_acls["public_outbound"], local.network_acls["default_outbound"])

  private_dedicated_network_acl   = true
  private_inbound_acl_rules       = concat(local.network_acls["public_inbound"], local.network_acls["default_inbound"])
  private_outbound_acl_rules      = concat(local.network_acls["public_outbound"], local.network_acls["default_outbound"])

  manage_default_network_acl = true

  create_igw = true

  # Single NAT gateway
  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}



