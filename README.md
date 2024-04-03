# Ansible

###### To use a containerized ldap app
docker run -p 389:389 -p 636:636 --name ldap-service -h ldap-service -e LDAP_ORGANISATION="confluent" -e LDAP_DOMAIN="confluent.io" -e LDAP_ADMIN_PASSWORD="confluent" -d osixia/openldap:latest

ldapadd -x -D "cn=admin,dc=confluent,dc=io" -w confluent -H ldap://localhost:391 -f users.ldif

###### List Users added
ldapsearch -x -D "cn=admin,dc=confluent,dc=io" -w confluent -H ldap://localhost:391 -LLL uid=* | grep uid: | cut -d: -f2 > results <br>
ldapsearch -x -D "cn=admin,dc=confluent,dc=io" -w confluent -H ldap://localhost:391 -LLL uid=*

###### Modify Users
ldapmodify -x -v -D "cn=admin,dc=confluent,dc=io" -w confluent -H ldap://localhost:391 -f usersmodify.ldif

###### Login in to Zookeeper Shell to Query Cluster/Broker/Topic Data

zookeeper-shell kafka-0.rrchakdc1.ans.test.io:2182 -zk-tls-config-file zookeeper-tls-client.properties <br>
get /config/brokers/<default>  <br>
ls /config/brokers/<default> --> to list <br>
ls /brokers/ids <br>
get /controller <br>

###### Observation

Noticed that could install community.general only from ansible-core 2.13.9

python3 -m pip install --user ansible-core==2.13.9 <br>
ansible-galaxy collection install community.general 


###### Sample audit log metadata commands

*confluent audit-log config describe* <br>
*confluent audit-log config update < audit-configs.json* <br>
*confluent audit-log config update --force < audit-configs.json* <br>
*confluent audit-log route list -r "crn:///kafka=*/topic=hr-*"* <br>
*confluent audit-log route lookup "crn:///kafka=<kafka-cluster-id>"* <br>

###### Sample Ansible Playbook and adhoc commands

*ansible-playbook -i mrchostsrbacmetric.yml confluent.platform.all* <br>
*ansible all -i mrchostsrbacdata.yml -m shell -a  'rm -R /var/lib/kafka; rm -R /opt/confluent; rm -R /var/lib/zookeeper'* <br>
*ansible all -i mrchostsrbacmetric.yml -m shell -a  'rm -R /etc/kafka; rm -R /etc/confluent*/; rm -R /etc/schema-registry*/;'* <br>
*ansible localhost -m shell -a  'ssh kafka-0.rrchakdc1.ans.test.io; ssh kafka-1.rrchakdc1.ans.test.io;'* <br>


###### Generate your component SSL Certificate
./ansible_cert_without_prompt.sh kafka-0 true — First time genereate the root authority certificate
 ./ansible_cert_without_prompt.sh kafka-1 false

###### For Secret Protection 
confluent secret master-key generate \
--local-secrets-file security.properties  \
--passphrase passphrase.txt
