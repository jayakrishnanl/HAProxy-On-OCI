resource "null_resource" "provision_inst" {
  count = "${var.lb_instance_count}"

  #depends_on = ["module.create_hap.ComputePrivateIPs"]
  connection {
    agent   = false
    timeout = "30m"
    host    = "${element(oci_core_public_ip.hap_public_ip.*.ip_address, count.index)}"
    user    = "opc"

    private_key = "${var.ssh_private_key}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y python-oci-cli",
      "sudo yum install -y haproxy keepalived",
      "sudo mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.orig",
      "sudo mv /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.orig",
      "sudo firewall-offline-cmd --port=80:tcp",
      "sudo firewall-offline-cmd --port=443:tcp",
      "sudo /bin/systemctl restart firewalld",
      "sudo firewall-cmd --add-rich-rule='rule protocol value=\"vrrp\" accept' --permanent",
      "sudo firewall-cmd --reload",
    ]
  }
}

resource "null_resource" "provision_services" {
  depends_on = ["null_resource.provision_inst"]
  count      = "${var.lb_instance_count}"

  connection {
    agent       = false
    timeout     = "30m"
    host        = "${element(oci_core_public_ip.hap_public_ip.*.ip_address, count.index)}"
    user        = "opc"
    private_key = "${var.ssh_private_key}"
  }

  provisioner "file" {
    content     = "${data.template_file.hapcfg.rendered}"
    destination = "/tmp/haproxy.cfg"
  }

  provisioner "file" {
    content     = "${element(data.template_file.kplcfg.*.rendered, count.index)}"
    destination = "/tmp/keepalived.conf"
  }

  provisioner "file" {
    content     = "${element(data.template_file.kpl_failover.*.rendered, count.index)}"
    destination = "/tmp/ip_failover.sh"
  }

  provisioner "file" {
    content     = "${element(data.template_file.kpl_failback.*.rendered, count.index)}"
    destination = "/tmp/ip_failback.sh"
  }

  provisioner "file" {
    content     = "${element(data.template_file.kpl_failback_sec.*.rendered, count.index)}"
    destination = "/tmp/ip_failback_sec.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp /tmp/haproxy.cfg /etc/haproxy/haproxy.cfg",
      "sudo cp /tmp/keepalived.conf /etc/keepalived/keepalived.conf",
      "sudo cp /tmp/ip_failover.sh /etc/keepalived/ip_failover.sh",
      "sudo cp /tmp/ip_failback.sh /etc/keepalived/ip_failback.sh",
      "sudo cp /tmp/ip_failback_sec.sh /etc/keepalived/ip_failback_sec.sh",
      "sudo chmod +x /etc/keepalived/ip_failover.sh",
      "sudo chmod +x /etc/keepalived/ip_failback.sh",
      "sudo chmod +x /etc/keepalived/ip_failback_sec.sh",
      "sudo systemctl enable haproxy",
      "sudo systemctl start haproxy",
      "sudo systemctl enable keepalived",
      "sudo systemctl start keepalived",
    ]
  }
}
