# Get list of Availability Domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = "${var.tenancy_ocid}"
}

# Get name of Availability Domains
data "template_file" "deployment_ad" {
  count    = "${length(var.AD)}"
  template = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD[count.index] - 1], "name")}"
}

# Get list of Fault Domains
data "oci_identity_fault_domains" "fds" {
  count               = "${length(var.AD)}"
  availability_domain = "${element(data.template_file.deployment_ad.*.rendered, count.index)}"
  compartment_id      = "${var.compartment_ocid}"
}

locals {
  fds                 = "${flatten(concat(data.oci_identity_fault_domains.fds.*.fault_domains))}"
  faultdomains_per_ad = 3
}

# Get name of Fault Domains
data "template_file" "deployment_fd" {
  template = "$${name}"
  count    = "${length(var.AD) * (local.faultdomains_per_ad) }"

  vars = {
    name = "${lookup(local.fds[count.index], "name")}"
  }
}

# Datasources for computing home region for IAM resources
data "oci_identity_tenancy" "tenancy" {
  tenancy_id = "${var.tenancy_ocid}"
}

data "oci_identity_regions" "home-region" {
  filter {
    name   = "key"
    values = ["${data.oci_identity_tenancy.tenancy.home_region_key}"]
  }
}

# Get services supported by Service Gateway in the Region
data "oci_core_services" "svcgtw_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

# Get a list of VNIC attachments on the Compute instances
data "oci_core_vnic_attachments" "InstanceVnicAttachments" {
  count               = "${length(var.AD)}"
  availability_domain = "${element(data.template_file.deployment_ad.*.rendered, count.index)}"
  compartment_id      = "${var.compartment_ocid}"
  instance_id         = "${element(module.create_hap.ComputeOcids, count.index)}"
}

locals {
  vnics = "${flatten(concat(data.oci_core_vnic_attachments.InstanceVnicAttachments.*.vnic_attachments))}"
}

# Get OCIDs of the Vnics
data "template_file" "vnic_ocids" {
  template = "$${name}"
  count    = "${var.lb_instance_count}"

  vars = {
    name = "${lookup(local.vnics[count.index], "vnic_id")}"
  }
}

data "oci_core_private_ips" "privateIpId" {
  depends_on = ["data.template_file.vnic_ocids"]

  # count      = "${length(data.template_file.vnic_ocids.*.rendered)}"
  count   = "${var.lb_instance_count}"
  vnic_id = "${element(data.template_file.vnic_ocids.*.rendered, count.index)}"

  filter {
    name   = "is_primary"
    values = ["true"]
  }
}

locals {
  privateIpId = "${flatten(concat(data.oci_core_private_ips.privateIpId.*.private_ips))}"
}

data "template_file" "privateIp_ocid" {
  template = "$${name}"
  count    = "${var.lb_instance_count}"

  vars = {
    name = "${lookup(local.privateIpId[count.index], "id")}"
  }
}

# Render inputs for HAProxy configuration file
data "template_file" "hapcfg" {
  template = "${file("${path.module}/userdata/hap.cfg.tpl")}"

  vars {
    web1_ip = "${element(module.create_web.ComputePrivateIPs, 0)}"
    web2_ip = "${element(module.create_web.ComputePrivateIPs, 1)}"
  }
}

locals {
  vrrp_id = ["1", "2"]
}

# Render inputs for keepalived configuration file
data "template_file" "kplcfg" {
  count    = "${var.lb_instance_count}"
  template = "${file("${path.module}/userdata/keepalived.conf.tpl")}"

  vars {
    hap1_ip = "${element(module.create_hap.ComputePrivateIPs, count.index)}"
    hap2_ip = "${element(module.create_hap.ComputePrivateIPs, count.index + 1)}"
    itr1    = "${element(local.vrrp_id, count.index)}"
    itr2    = "${element(local.vrrp_id, count.index + 1)}"
  }
}

data "template_file" "kpl_failover" {
  count    = "${var.lb_instance_count}"
  template = "${file("${path.module}/userdata/ip_failover.tpl")}"

  vars {
    PUB  = "${element(oci_core_public_ip.hap_public_ip.*.id, count.index + 1)}"
    PRIV = "${element(oci_core_private_ip.secPrivateIP.*.id, count.index)}"
  }
}

data "template_file" "kpl_failback" {
  count    = "${var.lb_instance_count}"
  template = "${file("${path.module}/userdata/ip_failback.tpl")}"

  vars {
    PUB  = "${element(oci_core_public_ip.hap_public_ip.*.id, count.index)}"
    PRIV = "${element(data.template_file.privateIp_ocid.*.rendered, count.index)}"
  }
}

data "template_file" "kpl_failback_sec" {
  count    = "${var.lb_instance_count}"
  template = "${file("${path.module}/userdata/ip_failback_sec.tpl")}"

  vars {
    PUB  = "${element(oci_core_public_ip.hap_public_ip.*.id, count.index + 1)}"
    PRIV = "${element(data.template_file.privateIp_ocid.*.rendered, count.index +1)}"
  }
}

data "template_file" "bootstrap_web" {
  template = "${file("${path.module}/userdata/bootstrap_web.tpl")}"

  vars {
    timezone = "${var.timezone}"
  }
}

data "template_file" "bootstrap_hap" {
  template = "${file("${path.module}/userdata/bootstrap_hap.tpl")}"

  vars {
    timezone = "${var.timezone}"
  }
}
