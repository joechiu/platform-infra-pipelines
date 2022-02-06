#!/bin/bash

encdir=/etc/mysql/encryption

mkdir -p $encdir
cd $encdir
for i in {1..4}; do openssl rand -hex 32 >> keyfile; done;
for i in {1..4}; do sed -i -e "$i s/^/$i;/" keyfile; done

openssl rand -hex 128 > keyfile.key

openssl enc -aes-256-cbc -md sha1 -pass file:keyfile.key -in keyfile -out keyfile.enc
