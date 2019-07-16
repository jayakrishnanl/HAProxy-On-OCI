#!/bin/bash

# This helper script will run the when HAProxy nodes recovers after a failure to failback Public IP to the original Primary Private IP. This runs from the new backup node as New Master node doesn't have Pub Ip yet.
  
OCI=`which oci`

# PUB = OCID of the Reserved Public IP of other hap node
# PRIV = OCID of Primary private IP address of other hap node

$OCI network public-ip update --public-ip-id ${PUB} --private-ip-id ${PRIV} --force --auth instance_principal
