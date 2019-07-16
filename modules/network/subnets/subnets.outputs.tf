output "subnetid" {
  value = ["${oci_core_subnet.subnet.*.id}"]
}

output "cidr_block" {
  value = ["${oci_core_subnet.subnet.*.cidr_block}"]
}
