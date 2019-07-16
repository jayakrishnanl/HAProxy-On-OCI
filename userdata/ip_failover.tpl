#!/bin/bash

# This helper script will run when the other HAProxy node (hap2) fail to migrate its Public IP to the secondary Private IP of this node (hap1). 
  
OCI=`which oci`

# PUB = OCID of the Reserved Public IP of other hap node
# PRIV = OCID of Secondary Private IP address of this hap node

$OCI network public-ip update --public-ip-id ${PUB} --private-ip-id ${PRIV} --force --auth instance_principal
