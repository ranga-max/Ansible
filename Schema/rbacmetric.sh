export PATH=$PATH:/home/ubuntu/confluent-7.3.1/bin
confluent login --ca-cert-path ./certs/ca-cert.pem --url https://kafka-2.rrchakdc1.ans.test.io:8090
cluster_id_cmd=$(confluent cluster describe --ca-cert-path ./certs/ca-cert.pem --url https://kafka-2.rrchakdc1.ans.test.io:8090)
cluster_id=$(echo $cluster_id_cmd | awk '{ print $12 }')
mip=192.168.75.7
#confluent cluster register   --cluster-name "metriccluster"   --kafka-cluster-id $cluster_id --hosts "$mip:443"   --protocol SASL_SSL
#confluent cluster register   --cluster-name "metriccluster-sr"   --kafka-cluster-id  $cluster_id   --schema-registry-cluster-id "schema-registry"   --hosts "$mip:443"   --protocol HTTPS
confluent cluster register   --cluster-name "metriccluster-ksql"   --kafka-cluster-id  $cluster_id   --ksql-cluster-id "metriccluster-ksql"   --hosts "$mip:443"   --protocol HTTPS
confluent cluster register   --cluster-name "metriccluster-connect"   --kafka-cluster-id  $cluster_id   --connect-cluster-id "metriccluster-connect"   --hosts "$mip:443"   --protocol HTTPS

confluent iam rbac role-binding create --principal User:c3 --role ClusterAdmin --kafka-cluster-id $cluster_id
confluent iam rbac role-binding create --principal User:c3 --role SystemAdmin --kafka-cluster-id $cluster_id
confluent iam rbac role-binding create --principal User:c3 --role SystemAdmin --kafka-cluster-id  $cluster_id  --schema-registry-cluster-id "schema-registry"
confluent iam rbac role-binding create --principal User:c3 --role SystemAdmin --kafka-cluster-id  $cluster_id --ksql-cluster-id "metriccluster-ksql"
confluent iam rbac role-binding create --principal User:c3 --role SystemAdmin --kafka-cluster-id  $cluster_id --connect-cluster-id "metriccluster-connect"

confluent iam rbac role-binding create --principal User:sr --role SystemAdmin --kafka-cluster-id  $cluster_id  --schema-registry-cluster-id "schema-registry"
confluent iam rbac role-binding create --principal User:ksql --role SystemAdmin --kafka-cluster-id  $cluster_id --ksql-cluster-id "metriccluster-ksqldb"
confluent iam rbac role-binding create --principal User:connect --role SystemAdmin --kafka-cluster-id  $cluster_id --connect-cluster-id "metriccluster-connect"

confluent iam rbac role-binding create --principal User:connect --role SystemAdmin --kafka-cluster-id $cluster_id
confluent iam rbac role-binding create --principal User:ksql --role SystemAdmin --kafka-cluster-id $cluster_id
confluent iam rbac role-binding create --principal User:sr --role SystemAdmin --kafka-cluster-id $cluster_id


