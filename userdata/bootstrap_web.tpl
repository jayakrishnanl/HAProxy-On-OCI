#cloud-config
timezone: "${timezone}"

packages:
  - nfs-utils
  - httpd
  - openssl
  - mod_ssl

runcmd:
 - systemctl start httpd
 - sudo systemctl enable httpd
 - [ sh, -c, "usermod -a -G apache opc" ]
 - [ sh, -c, "chown -R opc:apache /var/www" ]
 - chmod 2775 /var/www
 - [ find, /var/www, -type, d, -exec, chmod, 2775, {}, \; ]
 - [ find, /var/www, -type, f, -exec, chmod, 0664, {}, \; ]
 - [ sh, -c, 'echo "This is a test page" > /var/www/html/index.html' ]
 - sudo /bin/firewall-offline-cmd --add-port=80/tcp
 - sudo /bin/firewall-offline-cmd --add-port=443/tcp
 - sudo /bin/systemctl restart firewalld