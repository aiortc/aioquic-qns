FROM martenseemann/quic-network-simulator-endpoint:latest

RUN apt-get update
RUN apt-get install -y git-core libssl-dev python3-dev python3-pip
RUN git clone https://github.com/aiortc/aioquic && cd /aioquic && git checkout 79a8caf0044790c2a1764be8cad5835f9f9fbe76
WORKDIR /aioquic
RUN pip3 install . jinja2 starlette wsproto

COPY run_endpoint.sh .
RUN chmod +x run_endpoint.sh

ENTRYPOINT [ "./run_endpoint.sh" ]
