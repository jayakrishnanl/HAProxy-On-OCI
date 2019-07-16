# Compartment name
compartment_name = ""

# Region
region = ""

# AD (Availability Domain to use for creating infrastructure) 
AD = ["1","2"]

# CIDR block of VCN to be created
vcn_cidr =  ""

# DNS label of VCN to be created
vcn_dns_label = ""

# Display name for VCN
vcn_display_name = ""

# Timezone of compute instance
timezone = "GMT"

# Size of boot volume (in gb) of the instances
compute_boot_volume_size_in_gb = "50"

# Login user for instances
compute_instance_user = "opc"

# Hostname prefix to define name of LB nodes
lb_hostname_prefix = ""

# Number of HAProxy LB nodes to be created
lb_instance_count = "2"

# Haproxy Load balancer instance shape
lb_instance_shape = "VM.Standard2.1"

# Web tier Instance count
web_instance_count = "2"

# Web Tier instance shape
web_instance_shape = "VM.Standard2.1"

# Hostname prefix for Web Tier nodes
web_hostname_prefix = ""


