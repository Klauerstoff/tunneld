FROM alpine

LABEL org.opencontainers.image.source=https://github.com/ajquack/tunneld
LABEL org.opencontainers.image.title=tunneld
LABEL org.opencontainers.image.url=https://github.com/ajquack/tunneld
LABEL org.opencontainers.image.version=latest

COPY . /usr/bin/

RUN apk add --no-cache iptables iproute2 py3-pip && pip3 install kubernetes

RUN chmod +x /usr/bin/masquerade-to-services.py \
    echo "net.ipv4.ip_forward=1" > /etc/sysctl.conf

RUN touch crontab.tmp \
    && echo '* * * * * python3 /usr/bin/masquerade-to-services.py' > crontab.tmp \
    && crontab crontab.tmp \
    && rm -rf crontab.tmp

CMD ["/usr/sbin/crond", "-f", "-d", "0"]
