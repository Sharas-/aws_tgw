provider "aws" {
	version = "~> 2.15"
	region	= "eu-central-1"
}

locals {
	vpc1 = {"cidr" : "10.1.0.0/16"
					"subnet" : "10.1.0.0/24"
					"ip" : "10.1.0.4"}

	vpc2 = {"cidr" : "10.2.0.0/16"
					"subnet" : "10.2.0.0/24"
					"ip" : "10.2.0.4"}
	
	connectivity_test = <<-EOF
	#!/bin/bash
	ping %s
	EOF
}

resource "aws_vpc" "tgw_test1" {
	cidr_block = local.vpc1.cidr

	tags = {
		Name = "for_tgw_test1"
	}
}

resource "aws_vpc" "tgw_test2" {
	cidr_block = local.vpc2.cidr

	tags = {
		Name = "for_tgw_test2"
	}
}

resource "aws_subnet" "tgw_test1_private" {
	vpc_id = aws_vpc.tgw_test1.id
	cidr_block = local.vpc1.subnet

	tags = {
		Name = "tgw_test1_private"
	}
}

resource "aws_subnet" "tgw_test2_private" {
	vpc_id = aws_vpc.tgw_test2.id
	cidr_block = local.vpc2.subnet

	tags = {
		Name = "tgw_test2_private"
	}
}

resource "aws_instance" "tgw_test1_instace" {
	ami = "ami-090f10efc254eaf55" #Ubuntu, 18.04 LTS, amd64 bionic image build on 2019-02-12
	instance_type = "t2.micro"
	subnet_id = aws_subnet.tgw_test1_private.id
	private_ip = local.vpc1.ip
	user_data = "${format(local.connectivity_test, local.vpc2.ip)}"

	tags = {
		Name = "tgw_test1_instance"
	}
}

resource "aws_instance" "tgw_test2_instace" {
	ami = "ami-090f10efc254eaf55" #Ubuntu, 18.04 LTS, amd64 bionic image build on 2019-02-12
	instance_type = "t2.micro"
	subnet_id = aws_subnet.tgw_test2_private.id
	private_ip = local.vpc2.ip
	user_data = "${format(local.connectivity_test, local.vpc1.ip)}"

	tags = {
		Name = "tgw_test2_instance"
	}
}
