FROM alpine

LABEL org.opencontainers.image.source=https://github.com/ajquack/tunneld
LABEL org.opencontainers.image.title=tunneld-sidecard
LABEL org.opencontainers.image.url=https://github.com/ajquack/tunneld
LABEL org.opencontainers.image.version=latest

RUN apk add --no-cache wireguard-tools iptables iproute2 yq

COPY . /usr/bin/
RUN chmod +x /usr/bin/wg-init.sh && \
    echo "net.ipv4.ip_forward=1" > /etc/sysctl.conf && \
    mkdir /config
