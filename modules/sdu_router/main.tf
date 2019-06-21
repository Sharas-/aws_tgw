locals {
	amazon_side_asn = 64512	#used to identify amazon side for route propagation with VPN connections in BGP session.
}

resource "aws_ec2_transit_gateway" "sdu_router" {
	amazon_side_asn										=	local.amazon_side_asn
	auto_accept_shared_attachments		= "enable"
	default_route_table_association		= "enable" 
	default_route_table_propagation		= "enable"
	description												= "SDU router"
	dns_support												= "enable"
	vpn_ecmp_support									= "enable"
	tags = {
		Name = "sdu_router"
	}
} 

output "sdu_router" {
	value = aws_ec2_transit_gateway.sdu_router
}
