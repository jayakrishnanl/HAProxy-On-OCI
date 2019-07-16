#!/bin/bash

# This helper script will run the when HAProxy nodes recovers after a failure to failback Public IP to the original Primary Private IP.
  
OCI=`which oci`

# PUB = OCID of the Reserved Public IP of this hap node
# PRIV = OCID of Primary private IP address of this hap node

$OCI network public-ip update --public-ip-id ${PUB} --private-ip-id ${PRIV} --force --auth instance_principal
