# NGINX mTLS Proxy Test

Creating certificates

## CA
```shell
openssl genrsa -des3 -out MyCA.key 2048

openssl req -x509 -new -nodes -key MyCA.key -sha256 -days 1825 -out MyCA.pem

openssl x509 -in MyCA.pem -out MyCA.crt
```

VIEW
```shell
openssl x509 -noout -text -in MyCA.crt
```

### Other CA
```shell
openssl genrsa -des3 -out OtherCA.key 4096
openssl req -x509 -new -nodes -key OtherCA.key -sha256 -days 1825 -out OtherCA.pem
openssl x509 -in OtherCA.pem -out OtherCA.crt
```

## Server
```shell
#serer Key
openssl genrsa -out server.key 4096

#signing request
openssl req -new -sha256 -key server.key -out server.csr

#Server certificate
openssl x509 -req -in server.csr -CA MyCA.crt -CAkey MyCA.key -CAcreateserial -out server.crt -days 1000 -sha256
```

## Client
```shell
openssl genrsa -out client.key 4096

openssl req -new -sha256 -key client.key -out client.csr

openssl x509 -req -in client.csr -CA MyCA.crt -CAkey MyCA.key -CAcreateserial -out client.crt -days 1000 -sha256 
```

### Other Client
```shell
openssl genrsa -out client2.key 4096

openssl req -new -sha256 -key client2.key -out client2.csr

openssl x509 -req -in client2.csr -CA OtherCA.crt -CAkey OtherCA.key -CAcreateserial -out client2.crt -days 1000 -sha256 
```

## Running
```shell
docker build . -t my-nginx:proxy

docker run -it --rm -p 443:443 --net=host my-nginx:proxy
```

## Request

```shell
curl --insecure https://localhost/public
```

```shell
curl --insecure https://localhost/secure --cert client.crt --key client.key 
```

```shell
curl --insecure https://localhost/secure --cert client2.crt --key client2.key 
```

## Merged CA
```shell
cat MyCA.crt OtherCA.crt > merged.crt
```

# OpenSSl

```shell
➜ openssl verify -verbose -CAfile MyCA.crt client.crt 
client.crt: OK
➜ openssl verify -verbose -CAfile MyCA.crt client2.crt
C = BR, ST = SP, L = Ibate, O = Cliente 2, OU = eng, CN = Cliente 2 HTTP
error 20 at 0 depth lookup: unable to get local issuer certificate
error client2.crt: verification failed
➜ openssl verify -verbose -CAfile OtherCA.crt client.crt 
C = BR, ST = sao paulo, L = ibate, O = Andre client, OU = cleint, CN = Client HTTP
error 20 at 0 depth lookup: unable to get local issuer certificate
error client.crt: verification failed
➜ openssl verify -verbose -CAfile OtherCA.crt client2.crt
client2.crt: OK
➜ openssl verify -verbose -CAfile merged.crt client2.crt client.crt 
client2.crt: OK
client.crt: OK
```