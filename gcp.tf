provider "google" {
  version = "4.1.0"

  credentials = file("cred.json")

  project = "superproject-333310"
  region  = "us-east1"
  zone    = "us-east1-c"
}

// resource "google_compute_instance" "appserver" {
//   name = "secondary-application-server"
//   machine_type = "f1-micro"

//   boot_disk {
//    initialize_params {
//      image = "debian-cloud/debian-9"
//    }
// }
//  network_interface {
//    network = "default"
// }
// }

resource "google_compute_network" "vpc_network" {
  name                    = "vpc-aws-gcp"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

resource "google_compute_subnetwork" "subnet_1" {
  name          = "subnet-us-east-1"
  ip_cidr_range = "10.0.0.0/24"
  region        = "us-east1"
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_firewall" "allow_icmp_ssh" {
  name          = "allow-icmp-ssh"
  network       = google_compute_network.vpc_network.name
  source_ranges = ["0.0.0.0/0", "35.235.240.0/20"]

  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_router" "cloudrouter" {
  name    = "cloud-router-aws-gcp-vpn"
  network = google_compute_network.vpc_network.name
  region  = "us-east1"
  bgp {
    asn = 65420
  }
}

resource "google_compute_ha_vpn_gateway" "ha_gateway1" {
  region     = "us-east1"
  name       = "vpn-gateway-aws-gcp"
  network    = google_compute_network.vpc_network.id
  depends_on = [google_compute_network.vpc_network]
}

resource "google_compute_external_vpn_gateway" "external_gateway" {
  name            = "pvg-aws-gcp-vpn"
  redundancy_type = "FOUR_IPS_REDUNDANCY"
  description     = "An externally managed VPN gateway"
  interface {
    id         = 0
    ip_address = aws_vpn_connection.s2s_1.tunnel1_address
  }
  interface {
    id         = 1
    ip_address = aws_vpn_connection.s2s_1.tunnel2_address
  }
  interface {
    id         = 2
    ip_address = aws_vpn_connection.s2s_2.tunnel1_address
  }
  interface {
    id         = 3
    ip_address = aws_vpn_connection.s2s_2.tunnel2_address
  }
}

resource "google_compute_vpn_tunnel" "tunnel1_1" {
  name                            = "vpn-tunnel1-1"
  vpn_gateway                     = google_compute_ha_vpn_gateway.ha_gateway1.id
  peer_external_gateway           = google_compute_external_vpn_gateway.external_gateway.id
  peer_external_gateway_interface = 0
  shared_secret                   = aws_vpn_connection.s2s_1.tunnel1_preshared_key
  router                          = google_compute_router.cloudrouter.id
  vpn_gateway_interface           = 0
}

resource "google_compute_vpn_tunnel" "tunnel1_2" {
  name                            = "vpn-tunnel1-2"
  vpn_gateway                     = google_compute_ha_vpn_gateway.ha_gateway1.id
  peer_external_gateway           = google_compute_external_vpn_gateway.external_gateway.id
  peer_external_gateway_interface = 1
  shared_secret                   = aws_vpn_connection.s2s_1.tunnel2_preshared_key
  router                          = google_compute_router.cloudrouter.id
  vpn_gateway_interface           = 0
}

resource "google_compute_vpn_tunnel" "tunnel2_1" {
  name                            = "vpn-tunnel2-1"
  vpn_gateway                     = google_compute_ha_vpn_gateway.ha_gateway1.id
  peer_external_gateway           = google_compute_external_vpn_gateway.external_gateway.id
  peer_external_gateway_interface = 2
  shared_secret                   = aws_vpn_connection.s2s_2.tunnel1_preshared_key
  router                          = google_compute_router.cloudrouter.id
  vpn_gateway_interface           = 1
}

resource "google_compute_vpn_tunnel" "tunnel2_2" {
  name                            = "vpn-tunnel2-2"
  vpn_gateway                     = google_compute_ha_vpn_gateway.ha_gateway1.id
  peer_external_gateway           = google_compute_external_vpn_gateway.external_gateway.id
  peer_external_gateway_interface = 3
  shared_secret                   = aws_vpn_connection.s2s_2.tunnel2_preshared_key
  router                          = google_compute_router.cloudrouter.id
  vpn_gateway_interface           = 1
}

resource "google_compute_router_interface" "router1_interface1" {
  name       = "router1-interface1"
  router     = google_compute_router.cloudrouter.name
  ip_range   = "${aws_vpn_connection.s2s_1.tunnel1_cgw_inside_address}/30"
  vpn_tunnel = google_compute_vpn_tunnel.tunnel1_1.name
}

resource "google_compute_router_peer" "router1_peer1" {
  name                      = "bgp-tunnel-1-1"
  router                    = google_compute_router.cloudrouter.name
  peer_ip_address           = aws_vpn_connection.s2s_1.tunnel1_vgw_inside_address
  peer_asn                  = aws_vpn_gateway.vpn_gw.amazon_side_asn
  interface                 = google_compute_router_interface.router1_interface1.name
}

resource "google_compute_router_interface" "router1_interface2" {
  name       = "router1-interface2"
  router     = google_compute_router.cloudrouter.name
  ip_range   = "${aws_vpn_connection.s2s_1.tunnel2_cgw_inside_address}/30"
  vpn_tunnel = google_compute_vpn_tunnel.tunnel1_2.name
}

resource "google_compute_router_peer" "router1_peer2" {
  name                      = "bgp-tunnel-1-2"
  router                    = google_compute_router.cloudrouter.name
  peer_ip_address           = aws_vpn_connection.s2s_1.tunnel2_vgw_inside_address
  peer_asn                  = aws_vpn_gateway.vpn_gw.amazon_side_asn
  interface                 = google_compute_router_interface.router1_interface2.name
}

resource "google_compute_router_interface" "router2_interface1" {
  name       = "router2-interface1"
  router     = google_compute_router.cloudrouter.name
  ip_range   = "${aws_vpn_connection.s2s_2.tunnel1_cgw_inside_address}/30"
  vpn_tunnel = google_compute_vpn_tunnel.tunnel2_1.name
}

resource "google_compute_router_peer" "router2_peer1" {
  name                      = "bgp-tunnel-2-1"
  router                    = google_compute_router.cloudrouter.name
  peer_ip_address           = aws_vpn_connection.s2s_2.tunnel1_vgw_inside_address
  peer_asn                  = aws_vpn_gateway.vpn_gw.amazon_side_asn
  interface                 = google_compute_router_interface.router2_interface1.name
}

resource "google_compute_router_interface" "router2_interface2" {
  name       = "router2-interface2"
  router     = google_compute_router.cloudrouter.name
  ip_range   = "${aws_vpn_connection.s2s_2.tunnel2_cgw_inside_address}/30"
  vpn_tunnel = google_compute_vpn_tunnel.tunnel2_2.name
}

resource "google_compute_router_peer" "router2_peer2" {
  name                      = "bgp-tunnel-2-2"
  router                    = google_compute_router.cloudrouter.name
  peer_ip_address           = aws_vpn_connection.s2s_2.tunnel2_vgw_inside_address
  peer_asn                  = aws_vpn_gateway.vpn_gw.amazon_side_asn
  interface                 = google_compute_router_interface.router2_interface2.name
}