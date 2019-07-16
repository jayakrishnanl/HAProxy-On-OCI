# HAproxy Node Public IPs

output "haproxy_pub_ips" {
  description = "HAProxy - LB node - Public IPs for creating DNS A records"
  value = "{oci_core_public_ip.hap_public_ip.*.ip_address}"
}


