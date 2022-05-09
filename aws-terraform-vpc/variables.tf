variable "region" {
  description = "AWS Region"
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "192.168.0.0/24"
}

variable "public_subnets" {
  description = "AWS Region"
  type    = list(string)
  default = ["192.168.0.0/26", "192.168.0.64/26"]
}

variable "private_subnets" {
  description = "AWS Region"
  type    = list(string)
  default = ["192.168.0.128/26", "192.168.0.192/26"]
}

data "aws_ami_ids" "ubuntu" {
  owners = ["099720109477"] # Canonical

  filter {
      name   = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
      name   = "virtualization-type"
      values = ["hvm"]
  }
}

