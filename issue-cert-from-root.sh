#!/bin/sh
if [ -z ${1+x} ]; then
	echo "Need hostname argument";
else
	echo "Issuing certificate for '$1'";
	hostname=$1
	echo "Generating RSA key pair"
	openssl genrsa -out private/$hostname.key 2048
	openssl rsa -in private/$hostname.key -outform PEM -pubout -out $hostname.pub
	echo "Generating CSR"
	#openssl req -new -sha256 -key private/$hostname.key -out $hostname.csr
	touch conf/csr_config.cnf
	cat >> conf/csr_config.cnf <<EOF
[req]
prompt = no
distinguished_name = req_distinguished_name
req_extensions = v3_req

[req_distinguished_name]
C = GB
ST = London
L = London
O = Ezra
OU = $hostname
CN = $hostname

[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = $hostname
EOF
	openssl req \
		-config conf/csr_config.cnf \
		-new \
		-newkey rsa:2048 \
		-nodes \
		-subj "/CN=${hostname}/O=${hostname}/C=GB" \
		-keyout private/$hostname.key \
		-out $hostname.csr
	rm -rf conf/csr_config.cnf
	echo "Signing certificate"
	openssl ca -config conf/ezra.conf -in $hostname.csr -out $hostname.crt -extensions server_ext
	rm -rf $hostname.csr
	echo "Exporting"
	#openssl pkcs12 -export -inkey private/$hostname.key  -in $hostname.crt -name $hostname -out
	openssl pkcs12 -export -out $hostname.pfx -inkey private/$hostname.key -in $hostname.crt -certfile ezra.crt
fi
