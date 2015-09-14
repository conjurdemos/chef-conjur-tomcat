#!/bin/bash

echo "Setting Conjur config for environment"
export CONJUR_ACCOUNT="demo"
export CONJUR_APPLIANCE_URL="https://conjur/api"
export CONJUR_SSL_CERTIFICATE_PATH="/home/demo/conjur-demo.pem"
export CONJUR_HOST_IDENTITY="tomcat-01"


