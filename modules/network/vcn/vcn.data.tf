# Get Service gateway details

data "oci_core_services" "svcgtw_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}
