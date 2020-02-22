#!/bin/bash

# Set up the routing needed for the simulation.
/setup.sh

# The following variables are available for use:
# - ROLE contains the role of this execution context, client or server
# - SERVER_PARAMS contains user-supplied command line parameters
# - CLIENT_PARAMS contains user-supplied command line parameters

LOG_PARAMS=""
if [ -n "$SSLKEYLOGFILE" ]; then
    LOG_PARAMS="--secrets-log $SSLKEYLOGFILE"
fi

if [ -n "$TESTCASE" ]; then
    # interop runner
    case "$TESTCASE" in
        "handshake")
            CLIENT_PARAMS="--legacy-http"
            ;;
        "http3")
            ;;
        "multiconnect")
            CLIENT_PARAMS="--legacy-http"
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

run_client() {
    python3 examples/http3_client.py \
        --insecure \
        --output-dir /downloads \
        --verbose \
        $LOG_PARAMS \
        $CLIENT_PARAMS \
        $@ 2>> /logs/stderr.log
}

if [ "$ROLE" = "client" ]; then
    # Wait for the simulator to start up.
    /wait-for-it.sh sim:57832 -s -t 30

    echo "Starting client"
    case "$TESTCASE" in
    "multiconnect")
        for req in $REQUESTS; do
            echo $req
            run_client $req
        done
        ;;
    "resumption")
        arr=($REQUESTS)
        run_client ${arr[0]}
        run_client ${arr[@]:1}
        ;;
    *)
        run_client $REQUESTS
        ;;
    esac
elif [ "$ROLE" = "server" ]; then
    echo "Starting server"
    python3 examples/http3_server.py \
        --certificate tests/ssl_cert.pem \
        --port 443 \
        --private-key tests/ssl_key.pem \
        --verbose \
        $LOG_PARAMS \
        $SERVER_PARAMS 2>> /logs/stderr.log
fi
