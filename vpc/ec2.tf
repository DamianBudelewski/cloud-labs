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

module "bastion_security_group_ssh" {
  source  = "terraform-aws-modules/security-group/aws//modules/ssh"
  version = "~> 4.0"
  name    = "public-ssh-sg"
  vpc_id  = module.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_cidr_blocks = tolist([var.vpc_cidr])
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


