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
	openssl req -config conf/cert.conf -new -sha256 -key private/$hostname.key -out $hostname.csr
	echo "Signing certificate"
	openssl ca -config conf/ezra.conf -in $hostname.csr -out $hostname.crt -extensions server_ext
	rm -rf $hostname.csr
	echo "Exporting"
	openssl pkcs12 -export -inkey private/$hostname.key  -in $hostname.crt -name $hostname -out
	openssl pkcs12 -export -out $hostname.pfx -inkey private/$hostname.key -in $hostname.crt -certfile root-ca.crt

fi
