#!/bin/bash
#PRIV_KEY_FILE=/home/ubuntu/.ssh/xyz.pem
PRIV_KEY_FILE=/home/ubuntu/.ssh/bc_key_rrchak.pem
#create schemas to a custer in datacenter us east 1a
#STEP 1
export ANSIBLE_VERBOSITY=2
ansible-playbook --private-key ${PRIV_KEY_FILE} -i mrchostsrbacmetric.yml --extra-vars "@./schemadef.yml" testplay2.yml -vvvv
#ansible-playbook --private-key ${PRIV_KEY_FILE} -i inventory.yml --extra-vars "@./schemasdefdock.yml" schemas_management.yml -vvvv
#Just dump the schemas created from the previous step
#STEP 2
#ansible-playbook --private-key ${PRIV_KEY_FILE} -i mrchostsgenv1a.yml --extra-vars "@./schemasdef.yml" --extra-vars "dump_only=true" schemas_management.yml -vvvv
#Flip the input to dump to restore add restore only flag
#Restore the schemas to a custer in datacenter us east 1b
#STEP 3
#ansible-playbook --private-key ${PRIV_KEY_FILE} -i mrchostsgenv1b.yml --extra-vars "@./schema_dump_out.yml"  --extra-vars "restore_only=true" schemas_management.yml -vvvv
#ansible-playbook --private-key ${PRIV_KEY_FILE} -i mrchostsgenv1a.yml --extra-vars "@./schemasdef.yml" --extra-vars "delete_all_schemas=true" schemas_management.yml -vvvv
#ansible-playbook --private-key ${PRIV_KEY_FILE} -i mrchostsgenv1b.yml --extra-vars "@./schemasdef.yml" --extra-vars "delete_all_schemas=true" schemas_management.yml -vvvv

