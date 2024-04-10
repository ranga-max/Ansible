

CONFIGFILE=$1

kafka-configs --bootstrap-server kafka-2.rrchakdc1.ans.test.io:9093 --command-config sasl-ldap-mds.properties --entity-type brokers --entity-default --alter --add-config-file $CONFIGFILE
