module "fetchAWS_VPC_RTB" {
  source           = "digitickets/cli/aws"
  version          = "4.0.0"
  aws_cli_commands = ["ec2", "describe-route-tables --filters Name=vpc-id,Values=${var.AWS_VPC_ID}"]
  aws_cli_query    = "'RouteTables[0].Associations[0].RouteTableId'"
}

module "fetchAWS_VPC_Subnet" {
  source           = "digitickets/cli/aws"
  version          = "4.0.0"
  aws_cli_commands = ["ec2", "describe-subnets --filters Name=vpc-id,Values=${var.AWS_VPC_ID}"]
  aws_cli_query    = "'Subnets[*].SubnetId'"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = var.AWS_VPC_ID

  tags = {
    Name = "IGW"
  }
}

resource "aws_default_route_table" "example" {
  default_route_table_id = local.vpc_1_RTBid
  propagating_vgws       = [aws_vpn_gateway.vpn_gw.id]
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "rt-aws-gcp-vpc"
  }
  depends_on = [aws_vpn_gateway.vpn_gw]
}

resource "aws_route_table_association" "public" {
  subnet_id      = local.vpc_1_subnetids[0]
  route_table_id = aws_default_route_table.example.id
  depends_on     = [aws_default_route_table.example]
}

resource "aws_customer_gateway" "acg_1" {
  bgp_asn    = var.GCP_BGP
  ip_address = google_compute_ha_vpn_gateway.ha_gateway1.vpn_interfaces[0].ip_address
  type       = "ipsec.1"

  tags = {
    Name = "cg-aws-gcp-vpn-1"
  }
  depends_on = [google_compute_ha_vpn_gateway.ha_gateway1]
}

resource "aws_customer_gateway" "acg_2" {
  bgp_asn    = var.GCP_BGP
  ip_address = google_compute_ha_vpn_gateway.ha_gateway1.vpn_interfaces[1].ip_address
  type       = "ipsec.1"

  tags = {
    Name = "cg-aws-gcp-vpn-2"
  }
  depends_on = [google_compute_ha_vpn_gateway.ha_gateway1]
}

resource "aws_vpn_gateway" "vpn_gw" {
  vpc_id          = var.AWS_VPC_ID
  amazon_side_asn = var.AWS_BGP

  tags = {
    Name = "vpg-aws-gcp"
  }
}

resource "aws_vpn_connection" "s2s_1" {
  vpn_gateway_id                       = aws_vpn_gateway.vpn_gw.id
  customer_gateway_id                  = aws_customer_gateway.acg_1.id
  type                                 = "ipsec.1"
  tunnel1_phase1_encryption_algorithms = ["AES256"]
  tunnel1_phase2_encryption_algorithms = ["AES256"]
  tunnel1_phase1_integrity_algorithms  = ["SHA2-256"]
  tunnel1_phase2_integrity_algorithms  = ["SHA2-256"]
  tunnel1_phase1_dh_group_numbers      = ["14"]
  tunnel1_phase2_dh_group_numbers      = ["14"]
  tunnel1_ike_versions                 = ["ikev2"]

  tunnel2_phase1_encryption_algorithms = ["AES256"]
  tunnel2_phase2_encryption_algorithms = ["AES256"]
  tunnel2_phase1_integrity_algorithms  = ["SHA2-256"]
  tunnel2_phase2_integrity_algorithms  = ["SHA2-256"]
  tunnel2_phase1_dh_group_numbers      = ["14"]
  tunnel2_phase2_dh_group_numbers      = ["14"]
  tunnel2_ike_versions                 = ["ikev2"]

  tags = {
    Name = "vpn-aws-gcp-1"
  }
}

resource "aws_vpn_connection" "s2s_2" {
  vpn_gateway_id                       = aws_vpn_gateway.vpn_gw.id
  customer_gateway_id                  = aws_customer_gateway.acg_2.id
  type                                 = "ipsec.1"
  tunnel1_phase1_encryption_algorithms = ["AES256"]
  tunnel1_phase2_encryption_algorithms = ["AES256"]
  tunnel1_phase1_integrity_algorithms  = ["SHA2-256"]
  tunnel1_phase2_integrity_algorithms  = ["SHA2-256"]
  tunnel1_phase1_dh_group_numbers      = ["14"]
  tunnel1_phase2_dh_group_numbers      = ["14"]
  tunnel1_ike_versions                 = ["ikev2"]

  tunnel2_phase1_encryption_algorithms = ["AES256"]
  tunnel2_phase2_encryption_algorithms = ["AES256"]
  tunnel2_phase1_integrity_algorithms  = ["SHA2-256"]
  tunnel2_phase2_integrity_algorithms  = ["SHA2-256"]
  tunnel2_phase1_dh_group_numbers      = ["14"]
  tunnel2_phase2_dh_group_numbers      = ["14"]
  tunnel2_ike_versions                 = ["ikev2"]

  tags = {
    Name = "vpn-aws-gcp-2"
  }
}