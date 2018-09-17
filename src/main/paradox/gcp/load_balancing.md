# Cloud Load Balancing

## Load Balancers

### HTTP(S) Load Balancer

## SSL Certficates

The following example shows how to create a SSL certificate resource with a self-signed SSL certificate for the common name `*.example.net`.

```shell
# Create a private key file
$ openssl genrsa -out example.key 2048

# Create a CSR(Certificate-Singing-Request) file
$ openssl req -new -key example.key -out example.csr
...
-----
Country Name (2 letter code) [AU]:JP
State or Province Name (full name) [Some-State]:Tokyo
Locality Name (eg, city) []:
Organization Name (eg, company) [Internet Widgits Pty Ltd]:Self Signed Example
Organizational Unit Name (eg, section) []:
Common Name (e.g. server FQDN or YOUR name) []:*.example.net
Email Address []:

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:

# Generate a self-signed certiricate with the CSR file and the key file
$ openssl x509 -req -days 3650 -in example.csr -signkey example.key -out example.crt
Signature ok
subject=C = JP, ST = Tokyo, O = Self Signed Example, CN = *.example.net
Getting Private key

$ gcloud compute ssl-cetificates create wilidcard-example-net \
  --certificate example.crt \
  --private-key example.key
NAME                  CREATION_TIMESTAMP
wildcard-example-net  2018-01-23T01:23:45.000-07:00
```

@@@ warning { title=Caution }
In practice self-signed certificates are used for testing purpose only. You should never use self-signed certificates for public sites on production.
@@@

See also

* [Creating and Using SSL Certificates](https://cloud.google.com/load-balancing/docs/ssl-certificates)
* [gcloud compute ssl-certificates](https://cloud.google.com/sdk/gcloud/reference/compute/ssl-certificates/)
