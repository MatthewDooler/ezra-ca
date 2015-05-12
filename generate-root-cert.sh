#!/bin/sh
name=ezra
if [ ! -f $name.csr ] && [ ! -f $name.key ] && [ ! -f $name.crt ] && [ ! -f $name.crl ]; then
	openssl req -new -config conf/$name.conf -out $name.csr -keyout private/$name.key
	openssl ca -selfsign -config conf/$name.conf -in $name.csr -out $name.crt -extensions ca_ext
	openssl ca -gencrl -config conf/$name.conf -out $name.crl
else
	echo "$name.csr, $name.key, $name.crt and $name.crl must be manually deleted before re-generating the root certificate"
fi
