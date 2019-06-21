provider "aws" {
	version = "~> 2.15"
	region	= "eu-central-1"
}

module "sdu_router" {
	source = "../modules/sdu_router"
}
