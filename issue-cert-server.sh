#!/bin/sh
set -e
if [ -z ${1+x} ]; then
	echo "Usage: ./issue-cert-server.sh <cn>";
else
	echo "Issuing certificate for '$1'";
	CN=$1
	echo "Generating RSA key pair"
	openssl genrsa -out private/$CN.key 2048
	openssl rsa \
		-in private/$CN.key \
		-outform PEM \
		-pubout \
		-out $CN.pub
	echo "Generating CSR"
	rm -rf conf/csr_config.cnf
	touch conf/csr_config.cnf
	cat >> conf/csr_config.cnf <<EOF
[req]
prompt = no
distinguished_name = dn
req_extensions = req_ext

[dn]
C = GB
ST = London
L = London
O = Ezra
OU = Ezra
CN = $CN
emailAddress = webmaster@$CN

[req_ext]
subjectAltName = @alt_names

[alt_names]
DNS.1 = $CN
DNS.2 = www.$CN
EOF
	openssl req \
		-new \
		-config conf/csr_config.cnf \
		-keyout private/$CN.key \
		-out $CN.csr \
		-sha256 \
		-newkey rsa:2048 \
		-nodes \
		-extensions req_ext	
	rm -rf conf/csr_config.cnf
	echo "Signing certificate"
	openssl ca \
		-config conf/ezra.conf \
		-in $CN.csr \
		-out $CN.crt \
		-extensions server_ext
	rm -rf $CN.csr
	echo "Exporting"
	openssl pkcs12 -export \
		-out $CN.pfx \
		-inkey private/$CN.key \
		-in $CN.crt \
		-certfile ezra.crt
fi
