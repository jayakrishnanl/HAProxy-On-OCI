#cloud-config
timezone: "${timezone}"

packages:
  - nfs-utils

write_files:
  # Create file to be used when enabling ip forwarding
  - path: /etc/sysctl.d/98-ip-forward.conf
    content: |
		net.ipv4.ip_forward = 1
		net.ipv4.ip_nonlocal_bind = 1

runcmd:
	- sysctl -p /etc/sysctl.d/98-ip-forward.conf