#!/bin/sh
if [ -z ${1+x} ]; then
	echo "Need hostname argument";
else
	echo "Issuing certificate for '$1'";
	hostname=$1
	openssl genrsa -out private/$hostname.key 2048
	openssl rsa -in private/$hostname.key -outform PEM -pubout -out $hostname.pub
	openssl req -new -sha256 -key private/$hostname.key -out $hostname.csr
	openssl ca -config conf/ezra-root-ca.conf -in $hostname.csr -out $hostname.crt -extensions server_ext
fi
