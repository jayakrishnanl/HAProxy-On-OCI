output "ComputePrivateIPs" {
  value = ["${oci_core_instance.compute.*.private_ip}"]
}

output "ComputeOcids" {
  value = ["${oci_core_instance.compute.*.id}"]
}
