# Terraform AWS GCP connect - HA VPN
This independent module creates HA VPN connectivity between AWS and GCP.

You should have VPC on AWS and GCP side whose CIDR range must not overlap.
## Usage
~~~
module "aws-gcp-connect" {
  source           = "github.com/myanees284/aws-gcp-vpn"
  AWS_VPC_ID = "aws_vpc_id"
  // Optional input - AWS Side ASN (64512 - 65534, 4200000000 - 4294967294)
  AWS_BGP    = "64512"
  GCP_PROJECT  = "your_google_cloud_project_ID"
  //Provide your Google Cloud VPC Name, NOT ID!!!
  GCP_VPC_NAME = "gcp_vpc_name"
  // Optional input - Google ASN (64512 - 65534, 4200000000 - 4294967294)
  GCP_BGP      = "65420"
}
~~~
