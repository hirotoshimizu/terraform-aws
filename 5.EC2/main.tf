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

  tags = {
    Name = "terraform_aws_public_instance"
  }
}

resource "aws_instance" "private_server" {
  ami           = "ami-05207c56c1b903d1a"
  instance_type = "t2.micro"
  key_name = "terraform_keypair"
  subnet_id = aws_subnet.private-subnet-1a.id

  tags = {
    Name = "terraform_aws_private_instance"
  }
}
