#!/bin/sh
if [ -z ${1+x} ]; then
	echo "Need hostname argument";
else
	# TODO: Support for issuing for people (email addresses) rather than hosts (domain names)
	echo "Issuing certificate for '$1'";
	hostname=$1
	echo "Generating RSA key pair"
	openssl genrsa -out private/$hostname.key 2048
	openssl rsa \
		-in private/$hostname.key \
		-outform PEM \
		-pubout \
		-out $hostname.pub
	echo "Generating CSR"
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
CN = $hostname
emailAddress = webmaster@$hostname

[req_ext]
subjectAltName = @alt_names

[alt_names]
DNS.1 = $hostname
DNS.2 = www.$hostname
EOF
	openssl req \
		-new \
		-config conf/csr_config.cnf \
		-keyout private/$hostname.key \
		-out $hostname.csr \
		-sha256 \
		-newkey rsa:2048 \
		-nodes \
		-extensions req_ext	
	rm -rf conf/csr_config.cnf
	echo "Signing certificate"
	openssl ca \
		-config conf/ezra.conf \
		-in $hostname.csr \
		-out $hostname.crt \
		-extensions server_ext
	rm -rf $hostname.csr
	echo "Exporting"
	openssl pkcs12 -export \
		-out $hostname.pfx \
		-inkey private/$hostname.key \
		-in $hostname.crt \
		-certfile ezra.crt
fi
