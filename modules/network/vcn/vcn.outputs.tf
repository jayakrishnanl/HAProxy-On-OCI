output "vcnid" {
  description = "ocid of VCN"
  value       = "${oci_core_vcn.vcn.id}"
}

output "default_dhcp_id" {
  description = "ocid of default DHCP options"
  value       = "${oci_core_vcn.vcn.default_dhcp_options_id}"
}

output "igw_id" {
  description = "ocid of internet gateway"
  value       = "${oci_core_internet_gateway.igw.id}"
}

output "natgtw_id" {
  description = "ocid of service gateway"
  value       = "${oci_core_nat_gateway.natgtw.id}"
}

output "svcgtw_id" {
  description = "ocid of service gateway"
  value       = "${oci_core_service_gateway.svcgtw.id}"
}
