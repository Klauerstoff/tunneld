FROM alpine

LABEL org.opencontainers.image.source=https://github.com/ajquack/tunneld
LABEL org.opencontainers.image.title=tunneld-sidecard
LABEL org.opencontainers.image.url=https://github.com/ajquack/tunneld
LABEL org.opencontainers.image.version=latest

RUN apk add --no-cache wireguard-tools curl iptables iproute2

COPY . /usr/bin/
RUN chmod +x /usr/bin/generate-config.sh /usr/bin/add-interface.sh /usr/bin/add-route.sh /usr/bin/add-iptables.sh && \
    echo "net.ipv4.ip_forward=1" > /etc/sysctl.conf
