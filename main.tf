locals {
  // VCN is /16
  lb_subnet_prefix      = "${cidrsubnet("${var.vcn_cidr}", 6, 0)}"
  web_subnet_prefix     = "${cidrsubnet("${var.vcn_cidr}", 6, 1)}"
}

module "iam_dynamic_group" {
  source = "./modules/iam/dynamic-group/"

  providers = {
    "oci" = "oci.home"
  }

  tenancy_ocid              = "${var.tenancy_ocid}"
  dynamic_group_name        = "haproxy_dynamic_group"
  dynamic_group_description = "dynamic group created for HaProxy env"
  dynamic_group_rule        = "instance.compartment.id = '${var.compartment_ocid}'"
  policy_compartment_id     = "${var.compartment_ocid}"
  policy_compartment_name   = "${var.compartment_name}"
  policy_name               = "haproxy-dynamic-policy"
  policy_description        = "dynamic policy created for HaProxy env"

  policy_statements = ["Allow dynamic-group haproxy_dynamic_group to manage public-ips in compartment ${var.compartment_name}", "Allow dynamic-group haproxy_dynamic_group to manage private-ips in compartment ${var.compartment_name}"]
}

# Create VCN
module "create_vcn" {
  source           = "./modules/network/vcn"
  compartment_ocid = "${var.compartment_ocid}"
  vcn_cidr         = "${var.vcn_cidr}"
  vcn_dns_label    = "${var.vcn_dns_label}"
}

# Create HaProxy Tier Subnets
module "hap_subnet" {
  source = "./modules/network/subnets"

  compartment_ocid    = "${var.compartment_ocid}"
  AD                  = "${var.AD}"
  availability_domain = ["${data.template_file.deployment_ad.*.rendered}"]
  vcn_id              = "${module.create_vcn.vcnid}"

  vcn_subnet_cidr = [
    "${cidrsubnet(local.lb_subnet_prefix, 2, 0)}",
    "${cidrsubnet(local.lb_subnet_prefix, 2, 1)}",
    "${cidrsubnet(local.lb_subnet_prefix, 2, 2)}",
  ]

  dns_label         = "lb"
  dhcp_options_id   = "${module.create_vcn.default_dhcp_id}"
  route_table_id    = "${oci_core_route_table.PublicRT.id}"
  security_list_ids = ["${oci_core_security_list.LbSecList.id}"]
  private_subnet    = "False"
}

# Create WebTier subnets
module "web_subnet" {
  source = "./modules/network/subnets"

  compartment_ocid    = "${var.compartment_ocid}"
  AD                  = "${var.AD}"
  availability_domain = ["${data.template_file.deployment_ad.*.rendered}"]
  vcn_id              = "${module.create_vcn.vcnid}"

  vcn_subnet_cidr = [
    "${cidrsubnet(local.web_subnet_prefix, 2, 0)}",
    "${cidrsubnet(local.web_subnet_prefix, 2, 1)}",
    "${cidrsubnet(local.web_subnet_prefix, 2, 2)}",
  ]

  dns_label         = "web"
  dhcp_options_id   = "${module.create_vcn.default_dhcp_id}"
  route_table_id    = "${oci_core_route_table.PrivateRT.id}"
  security_list_ids = ["${oci_core_security_list.WebSecList.id}"]
  private_subnet    = "True"
}

# Create HAProxy Nodes --> need in 2 ADs and 2 nos
module "create_hap" {
  source = "./modules/compute"

  compartment_ocid               = "${var.compartment_ocid}"
  AD                             = "${var.AD}"
  availability_domain            = ["${data.template_file.deployment_ad.*.rendered}"]
  fault_domain                   = ["${sort(data.template_file.deployment_fd.*.rendered)}"]
  compute_subnet                 = ["${module.hap_subnet.subnetid}"]
  compute_instance_count         = "${var.lb_instance_count}"
  compute_hostname_prefix        = "${var.lb_hostname_prefix}${substr(var.region, 3, 3)}"
  compute_boot_volume_size_in_gb = "${var.compute_boot_volume_size_in_gb}"
  compute_assign_public_ip       = "false"
  compute_image                  = "${var.instance_image_ocid[var.region]}"
  compute_instance_shape         = "${var.lb_instance_shape}"
  compute_ssh_public_key         = "${var.ssh_public_key}"
  compute_ssh_private_key        = "${var.ssh_private_key}"
  compute_instance_user          = "${var.compute_instance_user}"
  timezone                       = "${var.timezone}"
  user_data                      = "${data.template_file.bootstrap_hap.rendered}"
}

# Create Web server backends
module "create_web" {
  source = "./modules/compute"

  compartment_ocid               = "${var.compartment_ocid}"
  AD                             = "${var.AD}"
  availability_domain            = ["${data.template_file.deployment_ad.*.rendered}"]
  fault_domain                   = ["${sort(data.template_file.deployment_fd.*.rendered)}"]
  compute_subnet                 = ["${module.web_subnet.subnetid}"]
  compute_instance_count         = "${var.web_instance_count}"
  compute_hostname_prefix        = "${var.web_hostname_prefix}${substr(var.region, 3, 3)}"
  compute_boot_volume_size_in_gb = "${var.compute_boot_volume_size_in_gb}"
  compute_assign_public_ip       = "false"
  compute_image                  = "${var.instance_image_ocid[var.region]}"
  compute_instance_shape         = "${var.web_instance_shape}"
  compute_ssh_public_key         = "${var.ssh_public_key}"
  compute_ssh_private_key        = "${var.ssh_private_key}"
  compute_instance_user          = "${var.compute_instance_user}"
  timezone                       = "${var.timezone}"
  user_data                      = "${data.template_file.bootstrap_web.rendered}"
}
