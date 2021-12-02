locals {
  vpc_1_RTBid     = module.fetchAWS_VPC_RTB.result
  vpc_1_subnetids = module.fetchAWS_VPC_Subnet.result
}