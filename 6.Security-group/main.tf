terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_vpc" "mainvpc" {
    cidr_block = "10.1.0.0/16"
}

resource "aws_subnet" "public-subnet-1a" {
    vpc_id = aws_vpc.mainvpc.id
    availability_zone = "ap-northeast-1a"
    cidr_block = "10.1.1.0/24"

    tags = {
      Name = "public-subnet"
    }
}

resource "aws_subnet" "private-subnet-1a" {
    vpc_id = aws_vpc.mainvpc.id
    availability_zone = "ap-northeast-1a"
    cidr_block = "10.1.2.0/24"

    tags = {
      Name = "private-subnet"
    }
}

resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.mainvpc.id

    tags = {
      Name = "main"
    }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.mainvpc.id

  tags = {
    Name = "public-rgb"
  }
}

resource "aws_route" "public" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id = aws_route_table.public.id
  gateway_id = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "public_1a" {
  subnet_id = aws_subnet.public-subnet-1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_instance" "public_server" {
  associate_public_ip_address = "true"
  ami           = "ami-05207c56c1b903d1a"
  instance_type = "t2.micro"
  key_name = "terraform_keypair"
  subnet_id = aws_subnet.public-subnet-1a.id
  vpc_security_group_ids = [aws_security_group.sg-public.id]

  tags = {
    Name = "terraform_aws_public_instance"
  }
}

resource "aws_instance" "private_server" {
  ami           = "ami-05207c56c1b903d1a"
  instance_type = "t2.micro"
  key_name = "terraform_keypair"
  subnet_id = aws_subnet.private-subnet-1a.id
  vpc_security_group_ids = [aws_security_group.sg-private.id]

  tags = {
    Name = "terraform_aws_private_instance"
  }
}

resource "aws_security_group" "sg-public" {
  vpc_id = aws_vpc.mainvpc.id
  name = "terraform-aws-public"
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_public" {
  from_port =  22
  to_port = 22
  ip_protocol = "tcp"
  cidr_ipv4 = "XXX.XX.XX.XX/32" # 使用しているIPに置き換えてください。
  security_group_id = aws_security_group.sg-public.id
  tags = {
    Name = "Sg for-terraform-aws-public"
  }
}

resource "aws_security_group" "sg-private" {
  vpc_id = aws_vpc.mainvpc.id
  name = "terraform-aws-private"
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_private" {
  from_port =  22
  to_port = 22
  ip_protocol = "tcp"
  cidr_ipv4 = "${aws_instance.public_server.private_ip}/32"
  security_group_id = aws_security_group.sg-private.id
  tags = {
    Name = "Sg for-terraform-aws-private"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_public" {
  ip_protocol = "-1"
  cidr_ipv4 = "0.0.0.0/0"
  security_group_id = aws_security_group.sg-public.id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_private" {
  ip_protocol = "-1"
  cidr_ipv4 = "0.0.0.0/0"
  security_group_id = aws_security_group.sg-private.id
}
