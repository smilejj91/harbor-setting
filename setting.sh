#!/bin/bash

read -p 'enter the version: ' VERSION

wget https://github.com/goharbor/harbor/releases/download/${VERSION}/harbor-offline-installer-${VERSION}.tgz

tar xvfz harbor-offline-installer-${VERSION}.tgz


# Create CA Certificates 
openssl genrsa -out harbor-ca.key 4096
openssl req -x509 -new -nodes -sha512 -days 3650 \
  -subj "/C=KR/O=Tmax/OU=OS1-2/CN=harbor-ca" \
  -key harbor-ca.key \
  -out harbor-ca.crt

# Create Server Certificates
openssl genrsa -out harbor.tmaxos.net.key 4096
openssl req -sha512 -new \
  -subj "/C=KR/O=Tmax/OU=OS1-2/CN=harbor.tmaxos.net" \
  -key harbor.tmaxos.net.key \
  -out harbor.tmaxos.net.csr

# SAN

cat >v3.ext<<EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1=harbor.tmaxos.net
DNS.2=tmaxos
EOF

openssl x509 -req -sha512 -days 3650 \
    -extfile v3.ext \
    -CA harbor-ca.crt -CAkey harbor-ca.key -CAcreateserial \
    -in harbor.tmaxos.net.csr \
    -out harbor.tmaxos.net.crt

openssl x509 -inform PEM -in harbor.tmaxos.net.crt -out harbor.tmaxos.net.cert

mkdir -p /etc/docker/certs.d/harbor.tmaxos.net
cp harbor.tmaxos.net.cert /etc/docker/certs.d/harbor.tmaxos.net/
cp harbor.tmaxos.net.key /etc/docker/certs.d/harbor.tmaxos.net/
cp harbor-ca.crt /etc/docker/certs.d/harbor.tmaxos.net/

cp harbor-ca.crt /usr/local/share/ca-certificates/
cp harbor.tmaxos.net.crt /usr/local/share/ca-certificates/
update-ca-certificates
systemctl restart docker


# harbor.yml

cp harbor.yml ./harbor/
cd ./harbor
./prepare
