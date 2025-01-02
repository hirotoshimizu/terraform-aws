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
