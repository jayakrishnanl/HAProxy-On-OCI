### OCI Creds for Terraform

## Update the values with your's

export TF_VAR_tenancy_ocid=ocid1.tenancy.oc1..aaaaaaaajd45ccu2jquva62syjosjah3vs5kuawqogx2hqih45timjxcc3ga
export TF_VAR_user_ocid=ocid1.user.oc1..aaaaaaaaxt2xu7ee4pedmjcqgu7qwf36uptyt3ncijjccwocumjbtbbrxeoa
export TF_VAR_compartment_ocid=ocid1.compartment.oc1..aaaaaaaadevbi7invfdahs6b57sa356po4efnvlhnbigqsjwhcpsz5yuaivq

### OCI API keys
export TF_VAR_private_key_path=/Users/jlakshma/.oci/oci_api_key.pem
export TF_VAR_fingerprint=b3:8f:55:5e:2e:a2:3a:37:e7:f2:a7:f4:86:a9:be:d4

### Region and Availability Domain
export TF_VAR_region=eu-frankfurt-1
export TF_VAR_availability_domain=1

### Public/Private keys used on the instance
### Replace with your key paths
export TF_VAR_ssh_public_key=$(cat /Users/jlakshma/opc.pub)
export TF_VAR_ssh_private_key=$(cat /Users/jlakshma/opc)

