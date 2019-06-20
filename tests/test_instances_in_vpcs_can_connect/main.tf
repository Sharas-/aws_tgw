provider "aws" {
	version = "~> 2.15"
	region	= "eu-central-1"
}

locals {
	vpc1 = {"cidr" : "10.1.0.0/16"
					"subnet" : "10.1.0.0/24"
					"ip" : "10.1.0.4"}

	vpc2 = {"cidr" : "10.1.0.0/16"
					"subnet" : "10.1.0.0/24"
					"ip" : "10.1.0.4"}
	
	connectivity_test = <<-EOF
	#!/bin/bash
	while true
	do
		ping %s
	done
	EOF
}

resource "aws_vpc" "tgw_test1" {
	cidr_block = local.vpc1.cidr

	tags = {
		Name = "for_tgw_test1"
	}
}

resource "aws_internet_gateway" "igw1"{
	vpc_id = aws_vpc.tgw_test1.id

	tags = {
		Name = "igw for test1"
	}
}

resource "aws_default_route_table" "r1" {
  default_route_table_id = aws_vpc.tgw_test1.default_route_table_id

  route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.igw1.id
  }
}

resource "aws_vpc" "tgw_test2" {
	cidr_block = local.vpc2.cidr

	tags = {
		Name = "for_tgw_test2"
	}
}

resource "aws_internet_gateway" "igw2"{
	vpc_id = aws_vpc.tgw_test2.id

	tags = {
		Name = "igw for test2"
	}
}

resource "aws_default_route_table" "r2" {
  default_route_table_id = aws_vpc.tgw_test2.default_route_table_id

  route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.igw2.id
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

resource aws_key_pair "sharo" {
	key_name = "sharo"
	public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCdoAFXx0DOW53j2TdALMtxdKArRmQuH2ZImuYwvW4bzba5R0AKY5wuzwk3TEPerBD+7SNsQUMavKfHQ7eQMzRRXqHinfNW/s1UHQjHFZs8vj4qtOe+eoiSQK5ZLyeTZZA+WneplIpFBa0VR/gPWVIorB42lPMTlnBR+yy/zqUoM2zMioitdagCponFtlR45JTxD4NNHOtWTpJyy7U7sqwx2r7IQVcML0qQLWlM7sQAVONCMon9NODILX/RoHB+t1eX1V2jGT9j2Q/B+UVvvt/j3WZDSqjzPpRcMHbQZp2n5YO+v8sws0gilGOLsPKGgC+fHt8AOjOp2EdBoucm10QX"
}

resource aws_security_group "ssh_and_ping1" {
		name = "ssh_and_ping1"
		vpc_id = aws_vpc.tgw_test1.id

		ingress {
			self = true
			from_port = 0
			to_port = 0
			protocol = "-1"
		}

		egress {
			self = true
			from_port = 0
			to_port = 0
			protocol = "-1"
		}

		ingress {
			from_port = -1
			to_port = -1
			cidr_blocks = ["0.0.0.0/0"]
			protocol = "icmp"
		}

		egress {
			from_port = -1
			to_port = -1
			cidr_blocks = ["0.0.0.0/0"]
			protocol = "icmp"
		}
}

resource aws_security_group "ssh_and_ping2" {
		name = "ssh_and_ping2"
		vpc_id = aws_vpc.tgw_test2.id
		
		egress {
			self = true 
			from_port = 0
			to_port = 0
			protocol = "-1"
		}

		ingress {
			self = true 
			from_port = 0
			to_port = 0
			protocol = "-1"
		}

		egress {
			from_port = -1
			to_port = -1
			cidr_blocks = ["0.0.0.0/0"]
			protocol = "icmp"
		}

		ingress {
			from_port = -1
			to_port = -1
			cidr_blocks = ["0.0.0.0/0"]
			protocol = "icmp"
		}
}

resource "aws_instance" "tgw_test1_instance" {
	ami = "ami-090f10efc254eaf55" #Ubuntu, 18.04 LTS, amd64 bionic image build on 2019-02-12
	instance_type = "t2.micro"
	subnet_id = aws_subnet.tgw_test1_private.id
	private_ip = local.vpc1.ip
	associate_public_ip_address = true
	key_name = "sharo"
	user_data = "${format(local.connectivity_test, local.vpc2.ip)}"
	vpc_security_group_ids = [aws_security_group.ssh_and_ping1.id]

	tags = {
		Name = "tgw_test1_instance"
	}
}

resource "aws_instance" "tgw_test2_instance" {
	ami = "ami-090f10efc254eaf55" #Ubuntu, 18.04 LTS, amd64 bionic image build on 2019-02-12
	instance_type = "t2.micro"
	subnet_id = aws_subnet.tgw_test2_private.id
	private_ip = local.vpc2.ip
	associate_public_ip_address = true
	key_name = "sharo"
	user_data = "${format(local.connectivity_test, local.vpc1.ip)}"
	vpc_security_group_ids = [aws_security_group.ssh_and_ping2.id]

	tags = {
		Name = "tgw_test2_instance"
	}
}
