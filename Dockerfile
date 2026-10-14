FROM martenseemann/quic-network-simulator-endpoint:latest

RUN apt-get update
RUN apt-get install -y git-core python3-dev python3-pip python3-venv
RUN git clone https://github.com/aiortc/aioquic && cd /aioquic && git checkout b88c8f10a140d145b2d33b9f2ac7fc5169a24da8
WORKDIR /aioquic
RUN python3 -m venv env
RUN env/bin/pip install . jinja2 starlette wsproto

COPY run_endpoint.sh .
RUN chmod +x run_endpoint.sh

ENTRYPOINT [ "./run_endpoint.sh" ]
