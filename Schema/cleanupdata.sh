ansible all -i mrchostsrbacdata.yml -m shell -a  'rm -R /var/lib/kafka*; rm -R /var/lib/confluent*; rm -R /var/log/kafka*; rm -R /var/log/confluent*; rm -R /opt/confluent; rm -R /var/lib/zookeeper'
