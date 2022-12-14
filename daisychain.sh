#!/usr/bin/bash

# make a Root CA directory structure wherever you want
mkdir root
cd root

mkdir tls
cd tls
# This will be used to keep a copy of the CA certificate’s private key.
mkdir certs private
# A serial file is used to keep track of the last serial number that was used to issue a certificate
echo 01 > serial
# create index.txt file which is a database of sorts that keeps track of the certificates that have been issued by the CA.
touch index.txt

# Add openssl.cnf for root CA
touch openssl.cnf

# create encrypted password file 
echo secret > mypass

openssl enc -aes256 -pbkdf2 -salt -in mypass -out mypass.enc


# ######## Actual Steps Starting with Root CA key creation #########
# Generate Root CA Private Key
openssl genrsa -des3 -passout file:mypass.enc -out private/cakey.pem 4096

# OpenSSL verify Root CA key
openssl rsa -noout -text -in private/cakey.pem -passin file:mypass.enc

# Create your own Root CA Certificate
openssl req -new -x509 -days 3650 -passin file:mypass.enc -config openssl.cnf -extensions v3_ca -key private/cakey.pem -out certs/cacert.pem

# To change the format of the certificate to PEM format (optional)
# openssl x509 -in certs/cacert.pem -out certs/cacert.pem -outform PEM

# Generate and configure a root openssl.cnf (Ask for file)

# OpenSSL verify Certificate
openssl x509 -noout -text -in certs/cacert.pem


# Create OpenSSL Intermediate CA directory structure
mkdir intermediate
cd intermediate
# We will also create sub directories under /intermediate to store our keys and certificate files. We will also need a serial and index.txt file as we created for our Root CA Certificate.
mkdir certs csr private
touch index.txt
echo 01 > serial
# Add a crlnumber file to the intermediate CA directory tree. crlnumber is used to keep track of certificate revocation lists.
echo 01 > crlnumber


##### FOR THIS STEP COPY THE PREVIOUS openssl.cnf INTO INTERMEDIATE AND MAKE THE FOLLOWING CHANGES IN THE INTERMEDIATE openssl.cnf
# dir             = /root/tls/intermediate               # Where everything is kept
# certificate     = $dir/certs/intermediate.cacert.pem   # The CA certificate
# private_key     = $dir/private/intermediate.cakey.pem  # The private key
# policy          = policy_anything

######## DEV CERT EXAMPLE ########

# Generate Intermediate CA key (Dev for example)
openssl genrsa -des3 -passout file:mypass.enc -out intermediate/private/dev.cakey.pem 4096

# go back to root folder
cd ..
pwd
#  Create intermediate CA Certificate Signing Request (CSR) 
openssl req -new -sha256 -config intermediate/openssl.cnf -passin file:mypass.enc  -key intermediate/private/dev.cakey.pem -out intermediate/csr/dev.csr.pem

# Sign and generate intermediate CA certificate
openssl ca -config openssl.cnf -extensions v3_intermediate_ca -days 2650 -notext -batch -passin file:mypass.enc -in intermediate/csr/dev.csr.pem -out intermediate/certs/dev.cacert.pem
# The index.txt file is where the OpenSSL ca tool stores the certificate database. Do not delete or edit this file by hand. It should now contain a line that refers to the intermediate certificate.
cat index.txt
# OpenSSL verify Certificate
openssl x509 -noout -text -in intermediate/certs/dev.cacert.pem

# Next openssl verify intermediate certificate against the root certificate. An OK indicates that the chain of trust is intact.
openssl verify -CAfile certs/cacert.pem intermediate/certs/dev.cacert.pem
openssl x509 -in intermediate/certs/dev.cacert.pem -out intermediate/certs/dev.cacert.pem -outform PEM

########## PROD CERT ##########

##### FOR THIS STEP COPY THE PREVIOUS openssl.cnf INTO INTERMEDIATE AND MAKE THE FOLLOWING CHANGES IN THE INTERMEDIATE prod.cnf
# dir             = /root/tls/intermediate               # Where everything is kept
# certificate     = $dir/certs/prod.cacert.pem   # The CA certificate
# private_key     = $dir/private/prod.cakey.pem  # The private key
# policy          = policy_anything

# Generate Intermediate CA key
openssl genrsa -des3 -passout file:mypass.enc -out intermediate/private/prod.cakey.pem 4096

#  Create intermediate CA Certificate Signing Request (CSR) 
openssl req -new -sha256 -config intermediate/openssl.cnf -passin file:mypass.enc  -key intermediate/private/prod.cakey.pem -out intermediate/csr/prod.csr.pem


# Sign and generate intermediate CA certificate
openssl ca -config prod.cnf -extensions v3_intermediate_ca -days 2650 -notext -batch -passin file:mypass.enc -in intermediate/csr/prod.csr.pem -out intermediate/certs/prod.cacert.pem
# The index.txt file is where the OpenSSL ca tool stores the certificate database. Do not delete or edit this file by hand. It should now contain a line that refers to the intermediate certificate.
cat index.txt
# OpenSSL verify Certificate
openssl x509 -noout -text -in intermediate/certs/prod.cacert.pem

# Next openssl verify intermediate certificate against the root certificate. An OK indicates that the chain of trust is intact.
openssl verify -CAfile certs/cacert.pem intermediate/certs/prod.cacert.pem

openssl x509 -in intermediate/certs/prod.cacert.pem -out intermediate/certs/prod.cacert.pem -outform PEM







####################################################################################################################################################################
####################################################################################################################################################################

########## POD1 Prod CERT ##########

##### FOR THIS STEP COPY THE PREVIOUS openssl.cnf INTO INTERMEDIATE AND MAKE THE FOLLOWING CHANGES IN THE INTERMEDIATE pod1-prod.cnf
# dir             = /root/tls/intermediate               # Where everything is kept
# certificate     = $dir/certs/pod1-prod.cacert.pem   # The CA certificate
# private_key     = $dir/private/pod1-prod.cakey.pem  # The private key
# policy          = policy_anything

# Generate Intermediate CA key
openssl genrsa -des3 -passout file:mypass.enc -out intermediate/private/pod1-prod.cakey.pem 4096

#  Create intermediate CA Certificate Signing Request (CSR) 
openssl req -new -sha256 -config intermediate/prod.cnf -passin file:mypass.enc  -key intermediate/private/pod1-prod.cakey.pem -out intermediate/csr/pod1-prod.csr.pem


# Sign and generate intermediate CA certificate
openssl ca -config pod1-prod.cnf -extensions v3_intermediate_ca -days 2650 -notext -batch -passin file:mypass.enc -in intermediate/csr/pod1-prod.csr.pem -out intermediate/certs/pod1-prod.cacert.pem
# The index.txt file is where the OpenSSL ca tool stores the certificate database. Do not delete or edit this file by hand. It should now contain a line that refers to the intermediate certificate.
cat index.txt
# OpenSSL verify Certificate
openssl x509 -noout -text -in intermediate/certs/pod1-prod.cacert.pem

# Next openssl verify intermediate certificate against the root certificate. An OK indicates that the chain of trust is intact.
openssl verify -CAfile certs/cacert.pem intermediate/certs/pod1-prod.cacert.pem

openssl x509 -in intermediate/certs/pod1-prod.cacert.pem -out intermediate/certs/pod1-prod.cacert.pem -outform PEM

########## POD2 Prod CERT ##########

##### FOR THIS STEP COPY THE PREVIOUS openssl.cnf INTO INTERMEDIATE AND MAKE THE FOLLOWING CHANGES IN THE INTERMEDIATE pod2-prod.cnf
# dir             = /root/tls/intermediate               # Where everything is kept
# certificate     = $dir/certs/pod2-prod.cacert.pem   # The CA certificate
# private_key     = $dir/private/pod2-prod.cakey.pem  # The private key
# policy          = policy_anything

# Generate Intermediate CA key
openssl genrsa -des3 -passout file:mypass.enc -out intermediate/private/pod2-prod.cakey.pem 4096

#  Create intermediate CA Certificate Signing Request (CSR) 
openssl req -new -sha256 -config intermediate/prod.cnf -passin file:mypass.enc  -key intermediate/private/pod2-prod.cakey.pem -out intermediate/csr/pod2-prod.csr.pem


# Sign and generate intermediate CA certificate
openssl ca -config pod2-prod.cnf -extensions v3_intermediate_ca -days 2650 -notext -batch -passin file:mypass.enc -in intermediate/csr/pod2-prod.csr.pem -out intermediate/certs/pod2-prod.cacert.pem
# The index.txt file is where the OpenSSL ca tool stores the certificate database. Do not delete or edit this file by hand. It should now contain a line that refers to the intermediate certificate.
cat index.txt
# OpenSSL verify Certificate
openssl x509 -noout -text -in intermediate/certs/pod2-prod.cacert.pem

# Next openssl verify intermediate certificate against the root certificate. An OK indicates that the chain of trust is intact.
openssl verify -CAfile certs/cacert.pem intermediate/certs/pod2-prod.cacert.pem

openssl x509 -in intermediate/certs/pod2-prod.cacert.pem -out intermediate/certs/pod2-prod.cacert.pem -outform PEM

########## POD1 Dev CERT ##########

##### FOR THIS STEP COPY THE PREVIOUS openssl.cnf INTO INTERMEDIATE AND MAKE THE FOLLOWING CHANGES IN THE INTERMEDIATE pod1-dev.cnf
# dir             = /root/tls/intermediate               # Where everything is kept
# certificate     = $dir/certs/pod1-dev.cacert.pem   # The CA certificate
# private_key     = $dir/private/pod1-dev.cakey.pem  # The private key
# policy          = policy_anything

# Generate Intermediate CA key
openssl genrsa -des3 -passout file:mypass.enc -out intermediate/private/pod1-dev.cakey.pem 4096

#  Create intermediate CA Certificate Signing Request (CSR) 
openssl req -new -sha256 -config intermediate/dev.cnf -passin file:mypass.enc  -key intermediate/private/pod1-dev.cakey.pem -out intermediate/csr/pod1-dev.csr.pem


# Sign and generate intermediate CA certificate
openssl ca -config pod1-dev.cnf -extensions v3_intermediate_ca -days 2650 -notext -batch -passin file:mypass.enc -in intermediate/csr/pod1-dev.csr.pem -out intermediate/certs/pod1-dev.cacert.pem
# The index.txt file is where the OpenSSL ca tool stores the certificate database. Do not delete or edit this file by hand. It should now contain a line that refers to the intermediate certificate.
cat index.txt
# OpenSSL verify Certificate
openssl x509 -noout -text -in intermediate/certs/pod1-dev.cacert.pem

# Next openssl verify intermediate certificate against the root certificate. An OK indicates that the chain of trust is intact.
openssl verify -CAfile certs/cacert.pem intermediate/certs/pod1-dev.cacert.pem

openssl x509 -in intermediate/certs/pod1-dev.cacert.pem -out intermediate/certs/pod1-dev.cacert.pem -outform PEM

########## POD2 Dev CERT ##########

##### FOR THIS STEP COPY THE PREVIOUS openssl.cnf INTO INTERMEDIATE AND MAKE THE FOLLOWING CHANGES IN THE INTERMEDIATE pod1-dev.cnf
# dir             = /root/tls/intermediate               # Where everything is kept
# certificate     = $dir/certs/pod2-dev.cacert.pem   # The CA certificate
# private_key     = $dir/private/pod2-dev.cakey.pem  # The private key
# policy          = policy_anything

# Generate Intermediate CA key
openssl genrsa -des3 -passout file:mypass.enc -out intermediate/private/pod2-dev.cakey.pem 4096

#  Create intermediate CA Certificate Signing Request (CSR) 
openssl req -new -sha256 -config intermediate/dev.cnf -passin file:mypass.enc  -key intermediate/private/pod2-dev.cakey.pem -out intermediate/csr/pod2-dev.csr.pem


# Sign and generate intermediate CA certificate
openssl ca -config pod2-dev.cnf -extensions v3_intermediate_ca -days 2650 -notext -batch -passin file:mypass.enc -in intermediate/csr/pod2-dev.csr.pem -out intermediate/certs/pod2-dev.cacert.pem
# The index.txt file is where the OpenSSL ca tool stores the certificate database. Do not delete or edit this file by hand. It should now contain a line that refers to the intermediate certificate.
cat index.txt
# OpenSSL verify Certificate
openssl x509 -noout -text -in intermediate/certs/pod2-dev.cacert.pem

# Next openssl verify intermediate certificate against the root certificate. An OK indicates that the chain of trust is intact.
openssl verify -CAfile certs/cacert.pem intermediate/certs/pod2-dev.cacert.pem

openssl x509 -in intermediate/certs/pod2-dev.cacert.pem -out intermediate/certs/pod2-dev.cacert.pem -outform PEM

########## Customer-A Pod1-Prod CERT ##########

##### FOR THIS STEP COPY THE PREVIOUS openssl.cnf INTO INTERMEDIATE AND MAKE THE FOLLOWING CHANGES IN THE INTERMEDIATE customer-a.cnf
# dir             = /root/tls/intermediate               # Where everything is kept
# certificate     = $dir/certs/customer-a.cacert.pem   # The CA certificate
# private_key     = $dir/private/customer-a.cakey.pem  # The private key
# policy          = policy_anything

# Generate Intermediate CA key
openssl genrsa -des3 -passout file:mypass.enc -out intermediate/private/customer-a.cakey.pem 4096

#  Create intermediate CA Certificate Signing Request (CSR) 
openssl req -new -sha256 -config intermediate/pod1-prod.cnf -passin file:mypass.enc  -key intermediate/private/customer-a.cakey.pem -out intermediate/csr/customer-a.csr.pem


# Sign and generate intermediate CA certificate
openssl ca -config customer-a.cnf -extensions v3_intermediate_ca -days 2650 -notext -batch -passin file:mypass.enc -in intermediate/csr/customer-a.csr.pem -out intermediate/certs/customer-a.cacert.pem
# The index.txt file is where the OpenSSL ca tool stores the certificate database. Do not delete or edit this file by hand. It should now contain a line that refers to the intermediate certificate.
cat index.txt
# OpenSSL verify Certificate
openssl x509 -noout -text -in intermediate/certs/customer-a.cacert.pem

# Next openssl verify intermediate certificate against the root certificate. An OK indicates that the chain of trust is intact.
openssl verify -CAfile certs/cacert.pem intermediate/certs/customer-a.cacert.pem

openssl x509 -in intermediate/certs/customer-a.cacert.pem -out intermediate/certs/customer-a.cacert.pem -outform PEM

########## Customer-B Pod1-Prod CERT ##########

##### FOR THIS STEP COPY THE PREVIOUS openssl.cnf INTO INTERMEDIATE AND MAKE THE FOLLOWING CHANGES IN THE INTERMEDIATE customer-b.cnf
# dir             = /root/tls/intermediate               # Where everything is kept
# certificate     = $dir/certs/customer-b.cacert.pem   # The CA certificate
# private_key     = $dir/private/customer-b.cakey.pem  # The private key
# policy          = policy_anything

# Generate Intermediate CA key
openssl genrsa -des3 -passout file:mypass.enc -out intermediate/private/customer-b.cakey.pem 4096

#  Create intermediate CA Certificate Signing Request (CSR) 
openssl req -new -sha256 -config intermediate/pod1-prod.cnf -passin file:mypass.enc  -key intermediate/private/customer-b.cakey.pem -out intermediate/csr/customer-b.csr.pem


# Sign and generate intermediate CA certificate
openssl ca -config customer-b.cnf -extensions v3_intermediate_ca -days 2650 -notext -batch -passin file:mypass.enc -in intermediate/csr/customer-b.csr.pem -out intermediate/certs/customer-b.cacert.pem
# The index.txt file is where the OpenSSL ca tool stores the certificate database. Do not delete or edit this file by hand. It should now contain a line that refers to the intermediate certificate.
cat index.txt
# OpenSSL verify Certificate
openssl x509 -noout -text -in intermediate/certs/customer-b.cacert.pem

# Next openssl verify intermediate certificate against the root certificate. An OK indicates that the chain of trust is intact.
openssl verify -CAfile certs/cacert.pem intermediate/certs/customer-b.cacert.pem

openssl x509 -in intermediate/certs/customer-b.cacert.pem -out intermediate/certs/customer-b.cacert.pem -outform PEM


########## Customer-AA Pod2-Prod CERT ##########

##### FOR THIS STEP COPY THE PREVIOUS openssl.cnf INTO INTERMEDIATE AND MAKE THE FOLLOWING CHANGES IN THE INTERMEDIATE customer-aa.cnf
# dir             = /root/tls/intermediate               # Where everything is kept
# certificate     = $dir/certs/customer-aa.cacert.pem   # The CA certificate
# private_key     = $dir/private/customer-aa.cakey.pem  # The private key
# policy          = policy_anything

# Generate Intermediate CA key
openssl genrsa -des3 -passout file:mypass.enc -out intermediate/private/customer-aa.cakey.pem 4096

#  Create intermediate CA Certificate Signing Request (CSR) 
openssl req -new -sha256 -config intermediate/pod2-prod.cnf -passin file:mypass.enc  -key intermediate/private/customer-aa.cakey.pem -out intermediate/csr/customer-aa.csr.pem


# Sign and generate intermediate CA certificate
openssl ca -config customer-aa.cnf -extensions v3_intermediate_ca -days 2650 -notext -batch -passin file:mypass.enc -in intermediate/csr/customer-aa.csr.pem -out intermediate/certs/customer-aa.cacert.pem
# The index.txt file is where the OpenSSL ca tool stores the certificate database. Do not delete or edit this file by hand. It should now contain a line that refers to the intermediate certificate.
cat index.txt
# OpenSSL verify Certificate
openssl x509 -noout -text -in intermediate/certs/customer-aa.cacert.pem

# Next openssl verify intermediate certificate against the root certificate. An OK indicates that the chain of trust is intact.
openssl verify -CAfile certs/cacert.pem intermediate/certs/customer-aa.cacert.pem

openssl x509 -in intermediate/certs/customer-aa.cacert.pem -out intermediate/certs/customer-aa.cacert.pem -outform PEM

########## Customer-BB Pod2-Prod CERT ##########

##### FOR THIS STEP COPY THE PREVIOUS openssl.cnf INTO INTERMEDIATE AND MAKE THE FOLLOWING CHANGES IN THE INTERMEDIATE customer-bb.cnf
# dir             = /root/tls/intermediate               # Where everything is kept
# certificate     = $dir/certs/customer-bb.cacert.pem   # The CA certificate
# private_key     = $dir/private/customer-bb.cakey.pem  # The private key
# policy          = policy_anything

# Generate Intermediate CA key
openssl genrsa -des3 -passout file:mypass.enc -out intermediate/private/customer-bb.cakey.pem 4096

#  Create intermediate CA Certificate Signing Request (CSR) 
openssl req -new -sha256 -config intermediate/pod2-prod.cnf -passin file:mypass.enc  -key intermediate/private/customer-bb.cakey.pem -out intermediate/csr/customer-bb.csr.pem


# Sign and generate intermediate CA certificate
openssl ca -config customer-bb.cnf -extensions v3_intermediate_ca -days 2650 -notext -batch -passin file:mypass.enc -in intermediate/csr/customer-bb.csr.pem -out intermediate/certs/customer-bb.cacert.pem
# The index.txt file is where the OpenSSL ca tool stores the certificate database. Do not delete or edit this file by hand. It should now contain a line that refers to the intermediate certificate.
cat index.txt
# OpenSSL verify Certificate
openssl x509 -noout -text -in intermediate/certs/customer-bb.cacert.pem

# Next openssl verify intermediate certificate against the root certificate. An OK indicates that the chain of trust is intact.
openssl verify -CAfile certs/cacert.pem intermediate/certs/customer-bb.cacert.pem

openssl x509 -in intermediate/certs/customer-bb.cacert.pem -out intermediate/certs/customer-bb.cacert.pem -outform PEM


####################################################################################################################################################################



echo "End of intermediate cert creation"

# OpenSSL Create Certificate Chain of trust (Certificate Bundle) (EXAMPLE follow 9. 10. and 11. when creating the actual chains)
# cat intermediate/certs/Dev.cacert.pem certs/ca_HL_Root_cert.pem > intermediate/certs/ca-chain-bundle.cert.pem

# OpenSSL verify Certificate Chain (EXAMPLE follow 9. 10. and 11. when creating the actual chains)
# openssl verify -CAfile certs/ca_HL_Root_cert.pem intermediate/certs/ca-chain-bundle.cert.pem



####### CREATE CERTIFICATE CHAIN OF TRUST #########

# OpenSSL Create Certificate Chain (Certificate Bundle)
# cat intermediate/certs/Prod.cacert.pem certs/ca_HL_Root_cert.pem > intermediate/certs/ca-chain-bundle.cert.pem

##### Root > Dev > POD1-Dev
cat certs/cacert.pem intermediate/certs/dev.cacert.pem intermediate/certs/pod1-dev.cacert.pem > intermediate/certs/ca-chain-bundle.cert.pem
##### Root > Dev > POD2-Dev
cat certs/cacert.pem intermediate/certs/dev.cacert.pem intermediate/certs/pod2-dev.cacert.pem > intermediate/certs/ca-chain-bundle.cert.pem

##### Root > Prod > POD1-Prod > Customer-A
cat certs/cacert.pem intermediate/certs/prod.cacert.pem intermediate/certs/pod1-prod.cacert.pem intermediate/certs/customer-a > intermediate/certs/ca-chain-bundle.cert.pem
##### Root > Prod > POD1-Prod > Customer-B
cat certs/cacert.pem intermediate/certs/prod.cacert.pem intermediate/certs/pod1-prod.cacert.pem intermediate/certs/customer-b > intermediate/certs/ca-chain-bundle.cert.pem

##### Root > Prod > POD2-Prod > Customer-AA
cat certs/cacert.pem intermediate/certs/prod.cacert.pem intermediate/certs/pod2-Prod.cacert.pem intermediate/certs/customer-aa > intermediate/certs/ca-chain-bundle.cert.pem
##### Root > Prod > POD2-Prod > cCstomer-BB
cat certs/cacert.pem intermediate/certs/prod.cacert.pem intermediate/certs/pod2-Prod.cacert.pem intermediate/certs/customer-bb > intermediate/certs/ca-chain-bundle.cert.pem

# OpenSSL verify Certificate Chain
openssl verify -CAfile certs/cacert.pem intermediate/certs/ca-chain-bundle.cert.pem

