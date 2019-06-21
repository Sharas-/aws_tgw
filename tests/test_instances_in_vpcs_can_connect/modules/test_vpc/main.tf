
variable vpc_nr { type = number }

resource "aws_vpc" "this" {
	cidr_block = "10.${var.vpc_nr}.0.0/16"

	tags = {
		Name = "tgw_test_vpc${var.vpc_nr}"
	}
}

resource "aws_subnet" "this" {
	vpc_id = aws_vpc.this.id
	cidr_block = "10.${var.vpc_nr}.0.0/24"

	tags = {
		Name = "tgw_test_subnet${var.vpc_nr}"
	}
}

resource "aws_internet_gateway" "this"{
	vpc_id = aws_vpc.this.id

	tags = {
		Name = "tgw_test_igw${var.vpc_nr}"
	}
}

resource "aws_default_route_table" "this" {
  default_route_table_id = aws_vpc.this.default_route_table_id

  route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.this.id
  }
}

resource aws_security_group "this" {
		name = "ssh_and_ping${var.vpc_nr}"
		vpc_id = aws_vpc.this.id

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
			from_port = 22
			to_port = 22
			protocol = "tcp"
			cidr_blocks = [ "0.0.0.0/0" ]
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

output "sg_id" {
	value = aws_security_group.this.id
}

output "subnet_id" {
	value = aws_subnet.this.id
}

