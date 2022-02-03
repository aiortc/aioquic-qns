FROM martenseemann/quic-network-simulator-endpoint:latest

RUN apt-get update
RUN apt-get install -y git-core libssl-dev python3-dev python3-pip
RUN pip3 install asgiref httpbin starlette wsproto
RUN git clone https://github.com/aiortc/aioquic && cd /aioquic && git checkout 0b282c9ce249c4f575963b6d587d682aab676621
WORKDIR /aioquic
RUN pip3 install -e .

COPY run_endpoint.sh .
RUN chmod +x run_endpoint.sh

ENTRYPOINT [ "./run_endpoint.sh" ]
