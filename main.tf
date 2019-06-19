provider "aws" {
	version = "~> 2.15"
	region	= "us-east-1"
}

locals {
	amazon_side_asn = 64512	#used to identify amazon side for route propagation with VPN connections in BGP session.
}

resource "aws_ec2_transit_gateway" "sdu_router" {
	amazon_side_asn										=	local.amazon_side_asn
	auto_accept_shared_attachments		= "enable"
	default_route_table_association		= "enable" 
	default_route_table_propagation		= "enable"
	description												= "all SDU routing zones interconnection"
	dns_support												= "enable"
	vpn_ecmp_support									= "enable"
} 

output "sdu_router" {
	value = aws_ec2_transit_gateway.sdu_router
}
