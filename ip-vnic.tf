# Create Reserved Public IP for HAP nodes.

resource "oci_core_public_ip" "hap_public_ip" {
  count          = "${var.lb_instance_count}"
  compartment_id = "${var.compartment_ocid}"
  lifetime       = "RESERVED"
  display_name   = "${var.lb_hostname_prefix}PubIP${element(var.AD,count.index)}${count.index + 1}"
  private_ip_id  = "${element(data.template_file.privateIp_ocid.*.rendered, count.index)}"
}

# Create secondary private IP
resource "oci_core_private_ip" "secPrivateIP" {
  count          = "${var.lb_instance_count}"
  vnic_id        = "${element(data.template_file.vnic_ocids.*.rendered, count.index)}"
  display_name   = "SecondaryIp${element(var.AD,count.index)}${count.index + 1}"
  hostname_label = "${var.lb_hostname_prefix}Sec${element(var.AD,count.index)}${count.index + 1}"
}

locals {
  cidr_block_priv = "${element(module.hap_subnet.cidr_block,0)}"
}

data "template_file" "create_nic_cfg" {
  count    = "${var.lb_instance_count}"
  template = "${file("${path.module}/userdata/SecIp.tpl")}"

  vars {
    sec_ip      = "${element(oci_core_private_ip.secPrivateIP.*.ip_address, count.index)}"
    sec_netmask = "${cidrnetmask(local.cidr_block_priv)}"
  }
}

resource "null_resource" "provision_secIpOs" {
  count = "${var.lb_instance_count}"

  connection {
    agent       = false
    timeout     = "30m"
    host        = "${element(oci_core_public_ip.hap_public_ip.*.ip_address, count.index)}"
    user        = "opc"
    private_key = "${var.ssh_private_key}"
  }

  provisioner "file" {
    content     = "${element(data.template_file.create_nic_cfg.*.rendered, count.index)}"
    destination = "/tmp/ens31"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/ens31 /etc/sysconfig/network-scripts/ifcfg-ens3:1",
      "sudo ifup ens3:1",
    ]
  }
}
