# Virtual Cloud Network (VCN)
resource "oci_core_vcn" "vcn" {
  compartment_id = "${var.compartment_ocid}"
  cidr_block     = "${var.vcn_cidr}"
  dns_label      = "${var.vcn_dns_label}"
  display_name   = "${var.vcn_dns_label}"
}

# Internet Gateway
resource "oci_core_internet_gateway" "igw" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "${var.vcn_dns_label}_igw"
  vcn_id         = "${oci_core_vcn.vcn.id}"
}

# NAT (Network Address Translation) Gateway
resource "oci_core_nat_gateway" "natgtw" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_vcn.vcn.id}"
  display_name   = "${var.vcn_dns_label}-natgtw"
}

# Service Gateway
resource "oci_core_service_gateway" "svcgtw" {
  compartment_id = "${var.compartment_ocid}"

  services {
    service_id = "${data.oci_core_services.svcgtw_services.services.0.id}"
  }

  vcn_id       = "${oci_core_vcn.vcn.id}"
  display_name = "svcgtw"
}
