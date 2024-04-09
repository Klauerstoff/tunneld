FROM busybox

LABEL org.opencontainers.image.source=https://github.com/ajquack/tunneld
LABEL org.opencontainers.image.title=tunneld-init
LABEL org.opencontainers.image.url=https://github.com/ajquack/tunneld
LABEL org.opencontainers.image.version=latest

# Copy the script into the container
COPY generate_wg_conf.sh /usr/local/bin/

# Make the script executable
RUN chmod +x /usr/local/bin/generate_wg_conf.sh

# Set the entry point to execute the script
ENTRYPOINT ["generate_wg_conf.sh"]
