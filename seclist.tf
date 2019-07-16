locals {
  tcp_protocol  = "6"
  udp_protocol  = "17"
  all_protocols = "all"
  vrrp_protocol = "112"
  anywhere      = "0.0.0.0/0"
  http_port     = "80"
  https_port    = "443"
  ssh_port      = "22"
}

resource "oci_core_security_list" "WebSecList" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "WebSecList"
  vcn_id         = "${module.create_vcn.vcnid}"

  egress_security_rules = [
    {
      protocol    = "${local.all_protocols}"
      destination = "${local.anywhere}"
      stateless   = false
    },
  ]

  ingress_security_rules = [
    {
      stateless = false

      tcp_options {
        "min" = "${local.ssh_port}"
        "max" = "${local.ssh_port}"
      }

      protocol = "${local.tcp_protocol}"
      source   = "${local.anywhere}"
    },
    {
      tcp_options {
        "min" = "${local.http_port}"
        "max" = "${local.http_port}"
      }

      protocol = "${local.tcp_protocol}"
      source   = "${var.vcn_cidr}"
    },
    {
      tcp_options {
        "min" = "${local.https_port}"
        "max" = "${local.https_port}"
      }

      protocol = "${local.tcp_protocol}"
      source   = "${var.vcn_cidr}"
    },
  ]
}

# Load Balancer Security List
resource "oci_core_security_list" "LbSecList" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "LbSecList"
  vcn_id         = "${module.create_vcn.vcnid}"

  egress_security_rules = [
    {
      protocol    = "${local.all_protocols}"
      destination = "${local.anywhere}"
      stateless   = false
    },
  ]

  ingress_security_rules = [
    {
      stateless = false

      tcp_options {
        "min" = "${local.ssh_port}"
        "max" = "${local.ssh_port}"
      }

      protocol = "${local.tcp_protocol}"
      source   = "${local.anywhere}"
    },
    {
      tcp_options {
        "min" = "${local.http_port}"
        "max" = "${local.http_port}"
      }

      protocol = "${local.tcp_protocol}"
      source   = "${local.anywhere}"
    },
    {
      tcp_options {
        "min" = "${local.https_port}"
        "max" = "${local.https_port}"
      }

      protocol = "${local.tcp_protocol}"
      source   = "${local.anywhere}"
    },
    {
      protocol = "${local.vrrp_protocol}"
      source   = "${var.vcn_cidr}"
    },
  ]
}
