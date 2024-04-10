
ansible all -i mrchostsrbacdata.yml -m shell -a  'pkill -9 -f "/opt/confluent/"'; 
ansible all -i mrchostsrbacdata.yml -m shell -a  'rm -R /var/lib/kafka*;'
ansible all -i mrchostsrbacdata.yml -m shell -a  'rm -R /var/lib/confluent*'
ansible all -i mrchostsrbacdata.yml -m shell -a  'rm -R /var/log/kafka*'
ansible all -i mrchostsrbacdata.yml -m shell -a  'rm -R /var/log/confluent*'
ansible all -i mrchostsrbacdata.yml -m shell -a  'rm -R /opt/confluent;'
ansible all -i mrchostsrbacdata.yml -m shell -a  'rm -R /var/lib/zookeeper'
