#! /bin/bash

if [ "$#" -ne 1 ]
then
  echo "Error: No domain name argument provided"
  echo "Usage: Provide a domain name as an argument"
  exit 1
fi

DOMAIN=$1

#openssl req -new -key ca-key.pem -x509 \
#  -days 1000 \
#  -out ca.pem \
#  -subj "/C=US/ST=CA/L=MountainView/O=Confluent/OU=Operator/CN=TestCA"

# 1. Generate CA's private key and self-signed certificate
#openssl genrsa -aes256 -passout pass:confluent -out ca-key.pem 4096
#openssl req -x509 -new -key ca-key.pem -passin pass:confluent -out ca-cert.pem -nodes -subj "/C=US/ST=CA/L=MountainView/O=Confluent/OU=Operator/CN=TestCA"

openssl req -x509 -newkey rsa:4096 -days 365 -keyout ca-key.pem -out ca-cert.pem -nodes -subj "/C=US/ST=CA/L=MountainView/O=Confluent/OU=Operator/CN=TestCA"

# Generate web server's private key and CSR
openssl genrsa -aes256 -passout pass:confluent -out ${DOMAIN}-key.pem 4096
openssl req -new -key ${DOMAIN}-key.pem -passin pass:confluent -out ${DOMAIN}-req.csr -nodes -subj "/C=US/ST=CA/L=MountainView/O=Confluent/OU=Operator/CN=cluster1.my.domain"

#openssl req -newkey rsa:4096 -keyout ${DOMAIN}-key.pem -passout pass:confluent -out ${DOMAIN}-req.csr -nodes -subj "/C=US/ST=CA/L=MountainView/O=Confluent/OU=Operator/CN=cluster1.my.domain"

# 3. Sign the web server's certificate request
##Default certificate validity
#openssl x509 -req -in server-req.csr -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem

#openssl x509 -req -in server-req.csr -days 365 -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem

# 4. 

cat > ${DOMAIN}-ext.cnf << EOF

subjectAltName=DNS:*.my.domain,DNS:kafka.my.domain,IP:172.192.0.1

EOF


openssl x509 -req -in ${DOMAIN}-req.csr -days 365 -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out ${DOMAIN}-cert.pem -extfile ${DOMAIN}-ext.cnf
#openssl x509 -req -in server-req.csr -days 365 -CA ca-cert.pem -CAkey ca-key.pem -passin pass:confluent -CAcreateserial -out server-cert.pem -extfile server-ext.cnf


#openssl x509 -req -in server-req.csr -days 365 -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem -ext "subjectAltName=DNS:*.my.domain,DNS:kafka.my.domain,IP:172.192.0.1" 

openssl pkcs12 -export \
    -in ${DOMAIN}-cert.pem \
    -inkey ${DOMAIN}-key.pem \
    -chain \
    -CAfile ca-cert.pem \
    -name ${DOMAIN} \
    -out ${DOMAIN}.p12 \
    -password pass:confluent

sudo keytool -importkeystore \
    -deststorepass confluent \
    -destkeystore ${DOMAIN}.keystore.pkcs12 \
    -srckeystore ${DOMAIN}.p12 \
    -deststoretype PKCS12  \
    -srcstoretype PKCS12 \
    -noprompt \
    -srcstorepass confluent

keytool -list -v \
    -keystore ${DOMAIN}.keystore.pkcs12 \
    -storepass confluent

keytool -importkeystore -srckeystore ${DOMAIN}.keystore.pkcs12 -srcstoretype pkcs12 \
 -srcalias ${DOMAIN} -srcstorepass confluent -destkeystore ${DOMAIN}.keystore.jks \
 -deststoretype jks -deststorepass confluent -destkeypass confluent -destalias ${DOMAIN}-jks

keytool -import -alias CAroot -file ca-cert.pem   -trustcacerts -keystore ${DOMAIN}.keystore.jks -storepass confluent -noprompt

sudo keytool -keystore ${DOMAIN}.truststore.jks \
    -alias CARoot \
    -import \
    -v -trustcacerts \
    -file ca-cert.pem \
    -storepass confluent  \
    -noprompt \
    -storetype JKS

keytool -list -v \
    -keystore ${DOMAIN}.keystore.jks \
    -storepass confluent

#rm -f *.cnf *.csr *.srl *.*12
