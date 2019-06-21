provider "aws" {
	version = "~> 2.15"
	region	= "eu-central-1"
}

module "vpc1" {
	source = "./modules/test_vpc"
	vpc_nr = 1
}

module "vpc2" {
	source = "./modules/test_vpc"
	vpc_nr = 2
}

resource aws_key_pair "sharo" {
	key_name = "sharo"
	public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCdoAFXx0DOW53j2TdALMtxdKArRmQuH2ZImuYwvW4bzba5R0AKY5wuzwk3TEPerBD+7SNsQUMavKfHQ7eQMzRRXqHinfNW/s1UHQjHFZs8vj4qtOe+eoiSQK5ZLyeTZZA+WneplIpFBa0VR/gPWVIorB42lPMTlnBR+yy/zqUoM2zMioitdagCponFtlR45JTxD4NNHOtWTpJyy7U7sqwx2r7IQVcML0qQLWlM7sQAVONCMon9NODILX/RoHB+t1eX1V2jGT9j2Q/B+UVvvt/j3WZDSqjzPpRcMHbQZp2n5YO+v8sws0gilGOLsPKGgC+fHt8AOjOp2EdBoucm10QX"
}

resource "aws_instance" "tgw_test_instance1" {
	ami = "ami-090f10efc254eaf55" #Ubuntu, 18.04 LTS, amd64 bionic image build on 2019-02-12
	instance_type = "t2.micro"
	associate_public_ip_address = true
	key_name = "sharo"
	vpc_security_group_ids = [module.vpc1.sg_id]
	subnet_id = module.vpc1.subnet_id

	tags = {
		Name = "tgw_test1_instance"
	}
}

resource "aws_instance" "tgw_test_instance2" {
	ami = "ami-090f10efc254eaf55" #Ubuntu, 18.04 LTS, amd64 bionic image build on 2019-02-12
	instance_type = "t2.micro"
	associate_public_ip_address = true
	key_name = "sharo"
	subnet_id = module.vpc2.subnet_id
	vpc_security_group_ids = [module.vpc2.sg_id]

	tags = {
		Name = "tgw_test2_instance"
	}
}
