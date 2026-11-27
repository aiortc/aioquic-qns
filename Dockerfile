FROM martenseemann/quic-network-simulator-endpoint:latest

RUN apt-get update
RUN apt-get install -y git-core python3-dev python3-pip python3-venv
RUN git clone https://github.com/aiortc/aioquic && cd /aioquic && git checkout 35ef1bfc4d6a6d278a6e838eb93bda4bc326a3cd
WORKDIR /aioquic
RUN python3 -m venv env
RUN env/bin/pip install . -r requirements/examples.txt

COPY run_endpoint.sh .
RUN chmod +x run_endpoint.sh

ENTRYPOINT [ "./run_endpoint.sh" ]
