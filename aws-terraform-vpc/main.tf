provider "aws" {
  region = var.region
}

terraform {
  required_version = "~> 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.58.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-bucket-mastering-aws-vpc"
    key            = "vpc/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = "true"
  }
}

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

################################################################################
# VPC
################################################################################

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

################################################################################
# EC2 - Bastion
################################################################################

module "bastion_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "BastionHost"

  ami                    = element(data.aws_ami_ids.ubuntu.ids,0)
  instance_type          = "t2.micro"
  key_name               = "mastering-aws"
  vpc_security_group_ids = [module.bastion_security_group_ssh.security_group_id]
  subnet_id              = element(module.vpc.public_subnets,0)

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "bastion_security_group_ssh" {
  source  = "terraform-aws-modules/security-group/aws//modules/ssh"
  version = "~> 4.0"
  name    = "public-ssh-sg"
  vpc_id  = module.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_cidr_blocks = tolist([var.vpc_cidr])
}

################################################################################
# EC2 - Application
################################################################################

module "application_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "ApplicationServer"

  ami                    = element(data.aws_ami_ids.ubuntu.ids,0)
  instance_type          = "t2.micro"
  key_name               = "mastering-aws"
  vpc_security_group_ids = [module.application_security_group_outbound_https.this_security_group_id,module.application_security_group_ssh.security_group_id]
  subnet_id              = element(module.vpc.private_subnets,0)

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "application_security_group_ssh" {
  source  = "terraform-aws-modules/security-group/aws//modules/ssh"
  version = "~> 4.0"
  name    = "private-ssh-sg"
  vpc_id  = module.vpc.vpc_id
  ingress_cidr_blocks = [element(var.public_subnets,0)]
}

module "application_security_group_outbound_https" {
  source  = "terraform-aws-modules/security-group/aws//modules/https-443"
  version = "~> 3.0"
  name    = "outbound-https-sg"
  vpc_id  = module.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}


