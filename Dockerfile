FROM martenseemann/quic-network-simulator-endpoint:latest

RUN apt-get update
RUN apt-get install -y git-core python3-dev python3-pip python3-venv
RUN git clone https://github.com/aiortc/aioquic && cd /aioquic && git checkout 4c3b10d360d0135642d587fdb6e59331deecc0ae
WORKDIR /aioquic
RUN python3 -m venv env
RUN env/bin/pip install . -r requirements/examples.txt

COPY run_endpoint.sh .
RUN chmod +x run_endpoint.sh

ENTRYPOINT [ "./run_endpoint.sh" ]
