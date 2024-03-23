# Ansible

###### To use a containerized ldap app
docker run -p 389:389 -p 636:636 --name ldap-service -h ldap-service -e LDAP_ORGANISATION="confluent" -e LDAP_DOMAIN="confluent.io" -e LDAP_ADMIN_PASSWORD="confluent" -d osixia/openldap:latest

ldapadd -x -D "cn=admin,dc=confluent,dc=io" -w confluent -H ldap://localhost:391 -f users.ldif

###### Generate your component SSL Certificate
./ansible_cert_without_prompt.sh kafka-0 true — First time genereate the root authority certificate
 ./ansible_cert_without_prompt.sh kafka-1 false

###### For Secret Protection 
confluent secret master-key generate \
--local-secrets-file security.properties  \
--passphrase passphrase.txt
