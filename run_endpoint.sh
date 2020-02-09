#!/bin/bash

# Set up the routing needed for the simulation.
/setup.sh

# The following variables are available for use:
# - ROLE contains the role of this execution context, client or server
# - SERVER_PARAMS contains user-supplied command line parameters
# - CLIENT_PARAMS contains user-supplied command line parameters

if [ "$ROLE" = "client" ]; then
    # Wait for the simulator to start up.
    /wait-for-it.sh sim:57832 -s -t 30
    echo "Starting client"
    python3 examples/http3_client.py \
        --insecure \
        --secrets-log /logs/ssl.log \
        --verbose \
        https://server/1000000
elif [ "$ROLE" = "server" ]; then
    echo "Starting server"
    python3 examples/http3_server.py \
        --certificate tests/ssl_cert.pem \
        --port 443 \
        --private-key tests/ssl_key.pem \
        --secrets-log /logs/ssl.log \
        --verbose
fi
