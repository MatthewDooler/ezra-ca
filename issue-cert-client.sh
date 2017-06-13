#!/bin/sh
set -e
if [ -z ${2+x} ]; then
	echo "Usage: ./issue-cert-client.sh <cn> <email>";
else
	CN=$1
	EMAIL=$2
	FILENAME="$CN $EMAIL"
	FILENAME=$(echo $FILENAME | tr -cd 'A-Za-z0-9_-' | tr '[:upper:]' '[:lower:]')
	echo "Issuing certificate for '$CN <$EMAIL>', will save output to $FILENAME";
	echo "Generating RSA key pair"
	openssl genrsa -out private/$FILENAME.key 2048
	openssl rsa \
		-in private/$FILENAME.key \
		-outform PEM \
		-pubout \
		-out $FILENAME.pub
	echo "Generating CSR"
	rm -rf conf/csr_config.cnf
	touch conf/csr_config.cnf
	cat >> conf/csr_config.cnf <<EOF
[req]
prompt = no
distinguished_name = dn

[dn]
C = GB
ST = London
L = London
O = Ezra
OU = Ezra
CN = $CN
emailAddress = $EMAIL
EOF
	openssl req \
		-new \
		-config conf/csr_config.cnf \
		-keyout private/$FILENAME.key \
		-out $FILENAME.csr \
		-sha256 \
		-newkey rsa:2048 \
		-nodes
	rm -rf conf/csr_config.cnf
	echo "Signing certificate"
	openssl ca \
		-config conf/ezra.conf \
		-in $FILENAME.csr \
		-out $FILENAME.crt \
		-extensions server_ext
	rm -rf $FILENAME.csr
	echo "Exporting"
	openssl pkcs12 -export \
		-out $FILENAME.pfx \
		-inkey private/$FILENAME.key \
		-in $FILENAME.crt \
		-certfile ezra.crt
fi
