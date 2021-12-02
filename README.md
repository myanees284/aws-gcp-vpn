# Terraform AWS GCP connect - HA VPN
This independent module creates HA VPN connectivity between AWS and GCP.

You should have VPC on AWS and GCP side whose CIDR range must not overlap.
## Usage
~~~
module "aws-gcp-connect" {
  source           = "github.com/myanees284/aws-gcp-vpn"
  AWS_VPC_ID = "AWS VPC ID"
  AWS_BGP    = "64512"
  GCP_PROJECT  = "superproject-333310"
  GCP_VPC_NAME = "gcp-vpc"
  GCP_BGP      = "65420"
}
~~~
