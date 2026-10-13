FROM martenseemann/quic-network-simulator-endpoint:latest

RUN apt-get update
RUN apt-get install -y git-core python3-dev python3-pip python3-venv
RUN git clone https://github.com/aiortc/aioquic && cd /aioquic && git checkout c6022273c4a5b12d49e11310616ca12f670674d5
WORKDIR /aioquic
RUN python3 -m venv env
RUN env/bin/pip install . jinja2 starlette wsproto

COPY run_endpoint.sh .
RUN chmod +x run_endpoint.sh

ENTRYPOINT [ "./run_endpoint.sh" ]
