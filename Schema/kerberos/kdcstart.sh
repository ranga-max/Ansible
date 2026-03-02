#!/bin/bash

docker exec -i kdc kadmin.local -w password -q "modprinc -maxrenewlife 11days +allow_renewable krbtgt/TEST.CONFLUENT.IO"  > /dev/null
### Create the required identities:
# Kafka service principal:
docker exec -i kdc kadmin.local -w password -q "add_principal -randkey kafka/broker.kerberos-demo.local@TEST.CONFLUENT.IO"  > /dev/null
docker exec -i kdc kadmin.local -w password -q "modprinc -maxlife 11days -maxrenewlife 11days +allow_renewable kafka/broker.kerberos-demo.local@TEST.CONFLUENT.IO"  > /dev/null
docker exec -i kdc kadmin.local -w password -q "add_principal -randkey kafka/broker2.kerberos-demo.local@TEST.CONFLUENT.IO"  > /dev/null
docker exec -i kdc kadmin.local -w password -q "modprinc -maxlife 11days -maxrenewlife 11days +allow_renewable kafka/broker2.kerberos-demo.local@TEST.CONFLUENT.IO"  > /dev/null
docker exec -i kdc kadmin.local -w password -q "add_principal -randkey kafka/broker3.kerberos-demo.local@TEST.CONFLUENT.IO"  > /dev/null
docker exec -i kdc kadmin.local -w password -q "modprinc -maxlife 11days -maxrenewlife 11days +allow_renewable kafka/broker3.kerberos-demo.local@TEST.CONFLUENT.IO"  > /dev/null

# Zookeeper service principal:
docker exec -i kdc kadmin.local -w password -q "add_principal -randkey zookeeper/zookeeper.kerberos-demo.local@TEST.CONFLUENT.IO"  > /dev/null
docker exec -i kdc kadmin.local -w password -q "modprinc -maxlife 11days -maxrenewlife 11days +allow_renewable zookeeper/zookeeper.kerberos-demo.local@TEST.CONFLUENT.IO"  > /dev/null

# Create a principal with which to connect to Zookeeper from brokers - NB use the same credential on all brokers!
docker exec -i kdc kadmin.local -w password -q "add_principal -randkey zkclient@TEST.CONFLUENT.IO"  > /dev/null
docker exec -i kdc kadmin.local -w password -q "modprinc -maxlife 11days -maxrenewlife 11days +allow_renewable zkclient@TEST.CONFLUENT.IO"  > /dev/null

# Create client principals to connect in to the cluster:
docker exec -i kdc kadmin.local -w password -q "add_principal -randkey kafka_producer@TEST.CONFLUENT.IO"  > /dev/null
docker exec -i kdc kadmin.local -w password -q "modprinc -maxlife 11days -maxrenewlife 11days +allow_renewable kafka_producer@TEST.CONFLUENT.IO"  > /dev/null
docker exec -i kdc kadmin.local -w password -q "add_principal -randkey kafka_producer/instance_demo@TEST.CONFLUENT.IO"  > /dev/null
docker exec -i kdc kadmin.local -w password -q "modprinc -maxlife 11days -maxrenewlife 11days +allow_renewable kafka_producer/instance_demo@TEST.CONFLUENT.IO"  > /dev/null
docker exec -i kdc kadmin.local -w password -q "add_principal -randkey kafka_consumer@TEST.CONFLUENT.IO"  > /dev/null
docker exec -i kdc kadmin.local -w password -q "modprinc -maxlife 11days -maxrenewlife 11days +allow_renewable kafka_consumer@TEST.CONFLUENT.IO"  > /dev/null
docker exec -i kdc kadmin.local -w password -q "add_principal -randkey connect@TEST.CONFLUENT.IO"  > /dev/null
docker exec -i kdc kadmin.local -w password -q "modprinc -maxlife 11days -maxrenewlife 11days +allow_renewable connect@TEST.CONFLUENT.IO"  > /dev/null
docker exec -i kdc kadmin.local -w password -q "add_principal -randkey schemaregistry@TEST.CONFLUENT.IO"  > /dev/null
docker exec -i kdc kadmin.local -w password -q "modprinc -maxlife 11days -maxrenewlife 11days +allow_renewable schemaregistry@TEST.CONFLUENT.IO"  > /dev/null
docker exec -i kdc kadmin.local -w password -q "add_principal -randkey ksqldb@TEST.CONFLUENT.IO"  > /dev/null
docker exec -i kdc kadmin.local -w password -q "modprinc -maxlife 11days -maxrenewlife 11days +allow_renewable ksqldb@TEST.CONFLUENT.IO"  > /dev/null
docker exec -i kdc kadmin.local -w password -q "add_principal -randkey controlcenter@TEST.CONFLUENT.IO"  > /dev/null
docker exec -i kdc kadmin.local -w password -q "modprinc -maxlife 11days -maxrenewlife 11days +allow_renewable controlcenter@TEST.CONFLUENT.IO"  > /dev/null
docker exec -i kdc kadmin.local -w password -q "add_principal -randkey conduktor@TEST.CONFLUENT.IO"  > /dev/null
docker exec -i kdc kadmin.local -w password -q "modprinc -maxlife 11days -maxrenewlife 11days +allow_renewable conduktor@TEST.CONFLUENT.IO"  > /dev/null

# Create an admin principal for the cluster, which we'll use to setup ACLs.
# Look after this - its also declared a super user in broker config.
docker exec -i kdc kadmin.local -w password -q "add_principal -randkey admin/for-kafka@TEST.CONFLUENT.IO"  > /dev/null
docker exec -i kdc kadmin.local -w password -q "modprinc -maxlife 11days -maxrenewlife 11days +allow_renewable admin/for-kafka@TEST.CONFLUENT.IO"  > /dev/null

# Create keytabs to use for Kafka
log "Create keytabs"
docker exec -i kdc rm -f /var/lib/secret/broker.keytab 2>&1 > /dev/null
docker exec -i kdc rm -f /var/lib/secret/broker2.keytab 2>&1 > /dev/null
docker exec -i kdc rm -f /var/lib/secret/broker3.keytab 2>&1 > /dev/null
docker exec -i kdc rm -f /var/lib/secret/zookeeper.keytab 2>&1 > /dev/null
docker exec -i kdc rm -f /var/lib/secret/zookeeper-client.keytab 2>&1 > /dev/null
docker exec -i kdc rm -f /var/lib/secret/kafka-client.keytab 2>&1 > /dev/null
docker exec -i kdc rm -f /var/lib/secret/kafka-admin.keytab 2>&1 > /dev/null
docker exec -i kdc rm -f /var/lib/secret/kafka-connect.keytab 2>&1 > /dev/null
docker exec -i kdc rm -f /var/lib/secret/kafka-schemaregistry.keytab 2>&1 > /dev/null
docker exec -i kdc rm -f /var/lib/secret/kafka-ksqldb.keytab 2>&1 > /dev/null
docker exec -i kdc rm -f /var/lib/secret/kafka-controlcenter.keytab 2>&1 > /dev/null
docker exec -i kdc rm -f /var/lib/secret/kafka-conduktor.keytab 2>&1 > /dev/null

docker exec -i kdc kadmin.local -w password -q "ktadd  -k /var/lib/secret/broker.keytab -norandkey kafka/broker.kerberos-demo.local@TEST.CONFLUENT.IO " > /dev/null
docker exec -i kdc kadmin.local -w password -q "ktadd  -k /var/lib/secret/broker2.keytab -norandkey kafka/broker2.kerberos-demo.local@TEST.CONFLUENT.IO " > /dev/null
docker exec -i kdc kadmin.local -w password -q "ktadd  -k /var/lib/secret/broker3.keytab -norandkey kafka/broker3.kerberos-demo.local@TEST.CONFLUENT.IO " > /dev/null
docker exec -i kdc kadmin.local -w password -q "ktadd  -k /var/lib/secret/zookeeper.keytab -norandkey zookeeper/zookeeper.kerberos-demo.local@TEST.CONFLUENT.IO " > /dev/null
docker exec -i kdc kadmin.local -w password -q "ktadd  -k /var/lib/secret/zookeeper-client.keytab -norandkey zkclient@TEST.CONFLUENT.IO " > /dev/null
docker exec -i kdc kadmin.local -w password -q "ktadd  -k /var/lib/secret/kafka-client.keytab -norandkey kafka_producer@TEST.CONFLUENT.IO " > /dev/null
docker exec -i kdc kadmin.local -w password -q "ktadd  -k /var/lib/secret/kafka-client.keytab -norandkey kafka_producer/instance_demo@TEST.CONFLUENT.IO " > /dev/null
docker exec -i kdc kadmin.local -w password -q "ktadd  -k /var/lib/secret/kafka-client.keytab -norandkey kafka_consumer@TEST.CONFLUENT.IO " > /dev/null
docker exec -i kdc kadmin.local -w password -q "ktadd  -k /var/lib/secret/kafka-admin.keytab -norandkey admin/for-kafka@TEST.CONFLUENT.IO " > /dev/null
docker exec -i kdc kadmin.local -w password -q "ktadd  -k /var/lib/secret/kafka-connect.keytab -norandkey connect@TEST.CONFLUENT.IO " > /dev/null
docker exec -i kdc kadmin.local -w password -q "ktadd  -k /var/lib/secret/kafka-schemaregistry.keytab -norandkey schemaregistry@TEST.CONFLUENT.IO " > /dev/null
docker exec -i kdc kadmin.local -w password -q "ktadd  -k /var/lib/secret/kafka-ksqldb.keytab -norandkey ksqldb@TEST.CONFLUENT.IO " > /dev/null
docker exec -i kdc kadmin.local -w password -q "ktadd  -k /var/lib/secret/kafka-controlcenter.keytab -norandkey controlcenter@TEST.CONFLUENT.IO " > /dev/null
docker exec -i kdc kadmin.local -w password -q "ktadd  -k /var/lib/secret/kafka-conduktor.keytab -norandkey conduktor@TEST.CONFLUENT.IO " > /dev/null

if [[ "$TAG" == *ubi8 ]] || version_gt $TAG_BASE "5.9.0"
then
  # https://github.com/vdesabou/kafka-docker-playground/issues/10
  # keytabs are created on kdc with root user
  # ubi8 images are using appuser user
  # starting from 6.0, all images are ubi8
  docker exec -i kdc chmod a+r /var/lib/secret/broker.keytab
  docker exec -i kdc chmod a+r /var/lib/secret/broker2.keytab
  docker exec -i kdc chmod a+r /var/lib/secret/broker3.keytab
  docker exec -i kdc chmod a+r /var/lib/secret/zookeeper.keytab
  docker exec -i kdc chmod a+r /var/lib/secret/zookeeper-client.keytab
  docker exec -i kdc chmod a+r /var/lib/secret/kafka-client.keytab
  docker exec -i kdc chmod a+r /var/lib/secret/kafka-admin.keytab
  docker exec -i kdc chmod a+r /var/lib/secret/kafka-connect.keytab
  docker exec -i kdc chmod a+r /var/lib/secret/kafka-schemaregistry.keytab
  docker exec -i kdc chmod a+r /var/lib/secret/kafka-ksqldb.keytab
  docker exec -i kdc chmod a+r /var/lib/secret/kafka-controlcenter.keytab
  docker exec -i kdc chmod a+r /var/lib/secret/kafka-conduktor.keytab
fi


# Adding ACLs for consumer and producer user:
docker exec client bash -c "kinit -k -t /var/lib/secret/kafka-admin.keytab admin/for-kafka && kafka-acls --bootstrap-server broker:9092 --command-config /etc/kafka/command.properties --add --allow-principal User:kafka_producer --producer --topic=*"
docker exec client bash -c "kinit -k -t /var/lib/secret/kafka-admin.keytab admin/for-kafka && kafka-acls --bootstrap-server broker:9092 --command-config /etc/kafka/command.properties --add --allow-principal User:kafka_consumer --consumer --topic=* --group=*"
# Adding ACLs for connect user:
docker exec client bash -c "kinit -k -t /var/lib/secret/kafka-admin.keytab admin/for-kafka && kafka-acls --bootstrap-server broker:9092 --command-config /etc/kafka/command.properties --add --allow-principal User:connect --consumer --topic=* --group=*"
docker exec client bash -c "kinit -k -t /var/lib/secret/kafka-admin.keytab admin/for-kafka && kafka-acls --bootstrap-server broker:9092 --command-config /etc/kafka/command.properties --add --allow-principal User:connect --producer --topic=*"
# schemaregistry and controlcenter is super user
