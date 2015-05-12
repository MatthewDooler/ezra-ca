#!/bin/sh
name=ezra
if [ ! -f $name.csr ] && [ ! -f private/$name.key ] && [ ! -f $name.crt ] && [ ! -f $name.crl ]; then
	touch db/index
	echo 01 > db/crlnumber
	openssl req -new -config conf/$name.conf -out $name.csr -keyout private/$name.key
	openssl ca -create_serial -selfsign -config conf/$name.conf -in $name.csr -out $name.crt -extensions ca_ext
	openssl ca -gencrl -config conf/$name.conf -out $name.crl
else
	echo "$name.csr private/$name.key $name.crt $name.crl must be manually deleted before re-generating the root certificate"
fi
