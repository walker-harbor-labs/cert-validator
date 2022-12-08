#!/usr/bin/bash

# make a Root CA directory structure wherever you want
mkdir cert-chain-validator
cd cert-chain-validator
# This will be used to keep a copy of the CA certificate’s private key.
mkdir certs private
# A serial file is used to keep track of the last serial number that was used to issue a certificate
echo 01 > serial
# create index.txt file which is a database of sorts that keeps track of the certificates that have been issued by the CA.
touch index.txt

# ######## Actual Steps Starting with Root CA key creation #########
# Generate Root CA Private Key
openssl genrsa -aes256 -out private/ca_HL_Root.key 4096

# OpenSSL verify Root CA key
openssl rsa -noout -text -in private/ca_HL_Root.key

# Create your own Root CA Certificate
openssl req -x509 -newkey rsa:4096 -keyout ca_HL_Root.key -out certs/ca_HL_Root_cert.pem -sha256 -days 365

# To change the format of the certificate to PEM format (optional)
# openssl x509 -in certs/ca_HL_Root_cert.pem -out certs/ca_HL_Root_cert.pem -outform PEM

# Generate and configure a root openssl.cnf (Ask for file)

# OpenSSL verify Certificate
openssl x509 -noout -text -in certs/ca_HL_Root_cert.pem


# Create OpenSSL Intermediate CA directory structure
mkdir intermediate
cd intermediate
# We will also create sub directories under /intermediate to store our keys and certificate files. We will also need a serial and index.txt file as we created for our Root CA Certificate.
mkdir certs csr private
touch index.txt
echo 01 > serial
# Add a crlnumber file to the intermediate CA directory tree. crlnumber is used to keep track of certificate revocation lists.
echo 01 > /intermediate/crlnumber

######## DEV CERT EXAMPLE ########

# Generate Intermediate CA key (Dev for example)
openssl genrsa -aes256 -out ./private/Dev.key 4096

# go back to root folder
cd ..
pwd
#  Create intermediate CA Certificate Signing Request (CSR) 
######### TODO: THIS IS THE ISSUE LINE CURRENTLY #############
openssl req -new -x509 -days 3650 -config ../openssl.cnf -sha256 -extensions v3_ca -key intermediate/private/Dev.key -out intermediate/csr/Dev.csr.pem

echo "Boing 1"
exit
echo "Boing 2"

# Sign and generate intermediate CA certificate
openssl ca -config openssl.cnf -days 2650 -notext -batch -in intermediate/csr/Dev.csr.pem -out intermediate/certs/Dev.cacert.pem
# The index.txt file is where the OpenSSL ca tool stores the certificate database. Do not delete or edit this file by hand. It should now contain a line that refers to the intermediate certificate.

# OpenSSL verify Certificate
openssl x509 -noout -text -in intermediate/certs/Dev.cacert.pem

# Next openssl verify intermediate certificate against the root certificate. An OK indicates that the chain of trust is intact.
openssl verify -CAfile certs/ca_HL_Root_cert.pem intermediate/certs/Dev.cacert.pem

# OpenSSL Create Certificate Chain of trust (Certificate Bundle) (EXAMPLE follow 9. 10. and 11. when creating the actual chains)
# cat intermediate/certs/Dev.cacert.pem certs/ca_HL_Root_cert.pem > intermediate/certs/ca-chain-bundle.cert.pem

# OpenSSL verify Certificate Chain (EXAMPLE follow 9. 10. and 11. when creating the actual chains)
# openssl verify -CAfile certs/ca_HL_Root_cert.pem intermediate/certs/ca-chain-bundle.cert.pem

######### END DEV CERT #########

######### PROD CERT #########

## Make sure you're in the intermediate folder, if not: cd intermediate

# Generate Intermediate CA key (Prod)
openssl genrsa -aes256 -out ./private/Prod.key 4096


#  Create intermediate CA Certificate Signing Request (CSR) 
openssl req -config openssl.cnf -new -sha256 -key intermediate/private/Prod.key -out intermediate/csr/Prod.csr.pem

# Sign and generate intermediate CA certificate
openssl ca -config openssl.cnf -days 2650 -notext -batch -in intermediate/csr/Prod.csr.pem -out intermediate/certs/Prod.cacert.pem

# OpenSSL verify Certificate
openssl x509 -noout -text -in intermediate/certs/Prod.cacert.pem

# Next openssl verify intermediate certificate against the root certificate. An OK indicates that the chain of trust is intact.
openssl verify -CAfile certs/ca_HL_Root_cert.pem intermediate/certs/Prod.cacert.pem


######### END PROD CERT #########



######### POD1-Dev (signed by Dev) CERT #########

## Make sure you're in the intermediate folder, if not: cd intermediate

# Generate Intermediate CA key (POD1-Dev)
openssl genrsa -aes256 -out ./private/POD1-Dev.key 4096


#  Create intermediate CA Certificate Signing Request (CSR) 
openssl req -config openssl.cnf -new -sha256 -key intermediate/private/POD1-Dev.key -out intermediate/csr/POD1-Dev.csr.pem

# Sign and generate intermediate CA certificate
openssl ca -config openssl.cnf -days 2650 -notext -batch -in intermediate/csr/POD1-Dev.csr.pem -out intermediate/certs/POD1-Dev.cacert.pem

# OpenSSL verify Certificate
openssl x509 -noout -text -in intermediate/certs/POD1-Dev.cacert.pem

# Next openssl verify intermediate certificate against the root certificate. An OK indicates that the chain of trust is intact.
openssl verify -CAfile intermediate/certs/Dev.cacert.pem intermediate/certs/POD1-Dev.cacert.pem


######### END POD1-Dev (signed by Dev) CERT #########

######### POD2-Dev (signed by Dev) CERT #########

## Make sure you're in the intermediate folder, if not: cd intermediate

# Generate Intermediate CA key (POD2-Dev)
openssl genrsa -aes256 -out ./private/POD2-Dev.key 4096


#  Create intermediate CA Certificate Signing Request (CSR) 
openssl req -config openssl.cnf -new -sha256 -key intermediate/private/POD2-Dev.key -out intermediate/csr/POD2-Dev.csr.pem

# Sign and generate intermediate CA certificate
openssl ca -config openssl.cnf -days 2650 -notext -batch -in intermediate/csr/POD2-Dev.csr.pem -out intermediate/certs/POD2-Dev.cacert.pem
# openssl ca -config openssl.cnf -days 2650 -notext -batch -in /csr/POD2-Dev.csr.pem -out /certs/POD2-Dev.cacert.pem

# OpenSSL verify Certificate
openssl x509 -noout -text -in intermediate/certs/POD2-Dev.cacert.pem

# Next openssl verify intermediate certificate against the root certificate. An OK indicates that the chain of trust is intact.
openssl verify -CAfile intermediate/certs/Dev.cacert.pem intermediate/certs/POD2-Dev.cacert.pem


######### END POD2-Dev (signed by Dev) CERT #########



######### POD1-Prod (signed by Prod) CERT #########

## Make sure you're in the intermediate folder, if not: cd intermediate

# Generate Intermediate CA key (POD1-Prod)
openssl genrsa -aes256 -out ./private/POD1-Prod.key 4096


#  Create intermediate CA Certificate Signing Request (CSR) 
openssl req -config openssl.cnf -new -sha256 -key intermediate/private/POD1-Prod.key -out intermediate/csr/POD1-Prod.csr.pem

# Sign and generate intermediate CA certificate
openssl ca -config openssl.cnf -days 2650 -notext -batch -in intermediate/csr/POD1-Prod.csr.pem -out intermediate/certs/POD1-Prod.cacert.pem

# OpenSSL verify Certificate
openssl x509 -noout -text -in intermediate/certs/POD1-Prod.cacert.pem

# Next openssl verify intermediate certificate against the root certificate. An OK indicates that the chain of trust is intact.
openssl verify -CAfile intermediate/certs/Prod.cacert.pem intermediate/certs/POD1-Prod.cacert.pem


######### END POD1-Prod (signed by Prod) CERT #########

######### POD2-Prod (signed by Prod) CERT #########

## Make sure you're in the intermediate folder, if not: cd intermediate

# Generate Intermediate CA key (POD2-Prod)
openssl genrsa -aes256 -out ./private/POD2-Prod.key 4096


#  Create intermediate CA Certificate Signing Request (CSR) 
openssl req -config openssl.cnf -new -sha256 -key intermediate/private/POD2-Prod.key -out intermediate/csr/POD2-Prod.csr.pem

# Sign and generate intermediate CA certificate
openssl ca -config openssl.cnf -days 2650 -notext -batch -in intermediate/csr/POD2-Prod.csr.pem -out intermediate/certs/POD2-Prod.cacert.pem

# OpenSSL verify Certificate
openssl x509 -noout -text -in intermediate/certs/POD2-Prod.cacert.pem

# Next openssl verify intermediate certificate against the root certificate. An OK indicates that the chain of trust is intact.
openssl verify -CAfile intermediate/certs/Prod.cacert.pem intermediate/certs/POD2-Prod.cacert.pem


######### END POD2-Prod (signed by Prod) CERT #########



######### Customer-A (signed by POD1-Prod) CERT #########

## Make sure you're in the intermediate folder, if not: cd intermediate

# Generate Intermediate CA key (Customer-A)
openssl genrsa -aes256 -out ./private/Customer-A.key 4096


#  Create intermediate CA Certificate Signing Request (CSR) 
openssl req -config openssl.cnf -new -sha256 -key intermediate/private/Customer-A.key -out intermediate/csr/Customer-A.csr.pem

# Sign and generate intermediate CA certificate
openssl ca -config openssl.cnf -days 2650 -notext -batch -in intermediate/csr/Customer-A.csr.pem -out intermediate/certs/Customer-A.cacert.pem

# OpenSSL verify Certificate
openssl x509 -noout -text -in intermediate/certs/Customer-A.cacert.pem

# Next openssl verify intermediate certificate against the root certificate. An OK indicates that the chain of trust is intact.
openssl verify -CAfile intermediate/certs/POD1-Prod.cacert.pem intermediate/certs/Customer-A.cacert.pem


######### END Customer-A (signed by POD1-Prod) CERT #########

######### Customer-B (signed by POD1-Prod) CERT #########

## Make sure you're in the intermediate folder, if not: cd intermediate

# Generate Intermediate CA key (Customer-B)
openssl genrsa -aes256 -out ./private/Customer-B.key 4096


#  Create intermediate CA Certificate Signing Request (CSR) 
openssl req -config openssl.cnf -new -sha256 -key intermediate/private/Customer-B.key -out intermediate/csr/Customer-B.csr.pem

# Sign and generate intermediate CA certificate
openssl ca -config openssl.cnf -days 2650 -notext -batch -in intermediate/csr/Customer-B.csr.pem -out intermediate/certs/Customer-B.cacert.pem

# OpenSSL verify Certificate
openssl x509 -noout -text -in intermediate/certs/Customer-B.cacert.pem

# Next openssl verify intermediate certificate against the root certificate. An OK indicates that the chain of trust is intact.
openssl verify -CAfile intermediate/certs/POD1-Prod.cacert.pem intermediate/certs/Customer-B.cacert.pem


######### END Customer-B (signed by POD1-Prod) CERT #########


######### Customer-AA (signed by POD2-Prod) CERT #########

## Make sure you're in the intermediate folder, if not: cd intermediate

# Generate Intermediate CA key (Customer-AA)
openssl genrsa -aes256 -out ./private/Customer-AA.key 4096


#  Create intermediate CA Certificate Signing Request (CSR) 
openssl req -config openssl.cnf -new -sha256 -key intermediate/private/Customer-AA.key -out intermediate/csr/Customer-AA.csr.pem

# Sign and generate intermediate CA certificate
openssl ca -config openssl.cnf -days 2650 -notext -batch -in intermediate/csr/Customer-AA.csr.pem -out intermediate/certs/Customer-AA.cacert.pem

# OpenSSL verify Certificate
openssl x509 -noout -text -in intermediate/certs/Customer-AA.cacert.pem

# Next openssl verify intermediate certificate against the root certificate. An OK indicates that the chain of trust is intact.
openssl verify -CAfile intermediate/certs/POD2-Prod.cacert.pem intermediate/certs/Customer-AA.cacert.pem


######### END Customer-AA (signed by POD2-Prod) CERT #########

######### Customer-BB (signed by POD2-Prod) CERT #########

## Make sure you're in the intermediate folder, if not: cd intermediate

# Generate Intermediate CA key (Customer-BB)
openssl genrsa -aes256 -out ./private/Customer-BB.key 4096


#  Create intermediate CA Certificate Signing Request (CSR) 
openssl req -config openssl.cnf -new -sha256 -key intermediate/private/Customer-BB.key -out intermediate/csr/Customer-BB.csr.pem

# Sign and generate intermediate CA certificate
openssl ca -config openssl.cnf -days 2650 -notext -batch -in intermediate/csr/Customer-BB.csr.pem -out intermediate/certs/Customer-BB.cacert.pem

# OpenSSL verify Certificate
openssl x509 -noout -text -in intermediate/certs/Customer-BB.cacert.pem

# Next openssl verify intermediate certificate against the root certificate. An OK indicates that the chain of trust is intact.
openssl verify -CAfile intermediate/certs/POD2-Prod.cacert.pem intermediate/certs/Customer-BB.cacert.pem


######### END Customer-BB (signed by POD2-Prod) CERT #########



####### CREATE CERTIFICATE CHAIN OF TRUST #########

# OpenSSL Create Certificate Chain (Certificate Bundle)
# cat intermediate/certs/Prod.cacert.pem certs/ca_HL_Root_cert.pem > intermediate/certs/ca-chain-bundle.cert.pem

##### Root > Dev > POD1-Dev
cat certs/ca_HL_Root_cert.pem intermediate/certs/Dev.cacert.pem intermediate/certs/POD1-Dev.cacert.pem > intermediate/certs/ca-chain-bundle.cert.pem
##### Root > Dev > POD2-Dev
cat certs/ca_HL_Root_cert.pem intermediate/certs/Dev.cacert.pem intermediate/certs/POD2-Dev.cacert.pem > intermediate/certs/ca-chain-bundle.cert.pem

##### Root > Prod > POD1-Prod > Customer-A
cat certs/ca_HL_Root_cert.pem intermediate/certs/Prod.cacert.pem intermediate/certs/POD1-Prod.cacert.pem intermediate/certs/Customer-A > intermediate/certs/ca-chain-bundle.cert.pem
##### Root > Prod > POD1-Prod > Customer-B
cat certs/ca_HL_Root_cert.pem intermediate/certs/Prod.cacert.pem intermediate/certs/POD1-Prod.cacert.pem intermediate/certs/Customer-B > intermediate/certs/ca-chain-bundle.cert.pem

##### Root > Prod > POD2-Prod > Customer-AA
cat certs/ca_HL_Root_cert.pem intermediate/certs/Prod.cacert.pem intermediate/certs/POD2-Prod.cacert.pem intermediate/certs/Customer-AA > intermediate/certs/ca-chain-bundle.cert.pem
##### Root > Prod > POD2-Prod > Customer-BB
cat certs/ca_HL_Root_cert.pem intermediate/certs/Prod.cacert.pem intermediate/certs/POD2-Prod.cacert.pem intermediate/certs/Customer-BB > intermediate/certs/ca-chain-bundle.cert.pem

# OpenSSL verify Certificate Chain
openssl verify -CAfile certs/ca_HL_Root_cert.pem intermediate/certs/ca-chain-bundle.cert.pem

