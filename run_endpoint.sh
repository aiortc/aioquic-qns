#!/bin/bash

# Set up the routing needed for the simulation.
/setup.sh

# The following variables are available for use:
# - ROLE contains the role of this execution context, client or server
# - SERVER_PARAMS contains user-supplied command line parameters
# - CLIENT_PARAMS contains user-supplied command line parameters

if [ -n "${TESTCASE}" ]; then
    # interop runner
    case "${TESTCASE}" in
        "handshake")
            CLIENT_PARAMS="--legacy-http"
            ;;
        "http3")
            ;;
        "resumption")
            CLIENT_PARAMS="--legacy-http --session-ticket session.ticket"
            ;;
        "retry")
            CLIENT_PARAMS="--legacy-http"
            SERVER_PARAMS="--stateless-retry"
            ;;
        "transfer")
            CLIENT_PARAMS="--legacy-http --max-data 262144 --max-stream-data 262144"
            ;;
        *)
            exit 127
            ;;
    esac

    if [ "$ROLE" = "server" ]; then
        export STATIC_ROOT=/www
    fi
else
    # network simulator
    REQUESTS="https://server/1000000"
fi

if [ "$ROLE" = "client" ]; then
    # Wait for the simulator to start up.
    /wait-for-it.sh sim:57832 -s -t 30
    echo "Starting client"
    if [ "$TESTCASE" = "resumption" ]; then
        arr=($REQUESTS)
        FIRST_REQUEST=${arr[0]}
        REQUESTS=${arr[@]:1}
        python3 examples/http3_client.py \
            --insecure \
            --output-dir /downloads \
            --secrets-log /logs/ssl.log \
            --verbose \
            $CLIENT_PARAMS \
            $FIRST_REQUEST 2>> /logs/stderr.log
    fi
    python3 examples/http3_client.py \
        --insecure \
        --output-dir /downloads \
        --secrets-log /logs/ssl.log \
        --verbose \
        $CLIENT_PARAMS \
        $REQUESTS 2>> /logs/stderr.log
elif [ "$ROLE" = "server" ]; then
    echo "Starting server"
    python3 examples/http3_server.py \
        --certificate tests/ssl_cert.pem \
        --port 443 \
        --private-key tests/ssl_key.pem \
        --secrets-log /logs/ssl.log \
        --verbose \
        $SERVER_PARAMS 2>> /logs/stderr.log
fi
