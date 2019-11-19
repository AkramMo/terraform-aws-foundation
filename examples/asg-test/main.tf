provider "aws" {
  region = "ap-northeast-1"
}

data "aws_availability_zones" "azs" {}

module "vpc" {
  source               = "fpco/foundation/aws//modules/vpc-scenario-1"
  cidr                 = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.0.0/24"]
  azs                  = data.aws_availability_zones.azs.names
  name_prefix          = "shida"
  region               = "ap-northeast-1"
}

module "ubuntu" {
  source = "fpco/foundation/aws//modules/ami-ubuntu"
}

resource "aws_security_group" "base" {
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "asg" {
  source = "../../modules/asg"
  security_group_ids = [aws_security_group.base.id]
  name_prefix = "shida"
  min_nodes = 2
  max_nodes = 5
  subnet_ids = module.vpc.public_subnet_ids
  ami = module.ubuntu.id
  key_name = "shida-tokyo"
  additional_block_devices = [{device_name = "/dev/sdl", volume_type = "gp2", volume_size = 15, encrypted = true}]
  user_data = "#!/bin/bash -"
}
