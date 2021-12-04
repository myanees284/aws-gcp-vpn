# Terraform AWS GCP connect - HA VPN
This independent module creates HA VPN connectivity between AWS and GCP.

You should have VPC on AWS and GCP side whose CIDR range must not overlap.
## Usage
~~~
module "aws-gcp-connect" {
  source           = "github.com/myanees284/aws-gcp-vpn"
  AWS_VPC_ID = "AWS VPC ID"
  // Optional input - AWS Side ASN (64512 - 65534, 4200000000 - 4294967294)
  AWS_BGP    = "64512"
  GCP_PROJECT  = "superproject-333310"
  GCP_VPC_NAME = "gcp-vpc"
  // Optional input - Google ASN (64512 - 65534, 4200000000 - 4294967294)
  GCP_BGP      = "65420"
}
~~~
