provider "aws" {
  region = "ap-northeast-1"
}

module "vpc" {
  source      = "../../modules/vpc-scenario-1"
  name_prefix = "test"
  region = "ap-northeast-1"
  cidr = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.0.0/24"]
  azs = ["ap-northeast-1a"]
}

module "ubuntu" {
  source = "fpco/foundation/aws//modules/ami-ubuntu"
}

module "asg" {
  source = "../../modules/single-node-asg"
  name_prefix = "test"
  subnet_id = module.vpc.public_subnet_ids[0]
  security_group_ids = [aws_security_group.base.id]
  region = "ap-northeast-1"
  instance_type = "t2.micro"
  key_name = "shida-tokyo"
  name_suffix = "shida"
  ami = module.ubuntu.id
}

resource "aws_security_group" "base" {
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

