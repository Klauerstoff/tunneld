FROM alpine

LABEL org.opencontainers.image.source=https://github.com/ajquack/tunneld
LABEL org.opencontainers.image.title=tunneld
LABEL org.opencontainers.image.url=https://github.com/ajquack/tunneld
LABEL org.opencontainers.image.version=latest

RUN apk add --no-cache wireguard-tools bash wget openresolv iptables

COPY docker-entrypoint.sh /usr/bin/

RUN echo "net.ipv4.ip_forward=1" > /etc/sysctl.conf

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["wg-quick", "up", "wg0"]
