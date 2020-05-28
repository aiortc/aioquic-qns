#!/bin/sh

set -e

docker build -t aiortc/aioquic-qns:latest .
docker push aiortc/aioquic-qns:latest
