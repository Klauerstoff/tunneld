#!/bin/sh

# Define variables from environment variables
PRIVATE_KEY="$PRIVATE_KEY"
ADDRESS="$ADDRESS"
PRE_UP_COMMAND="$PRE_UP_COMMAND"
PEER_PUBLIC_KEY="$PEER_PUBLIC_KEY"
ENDPOINT="$ENDPOINT"
ALLOWED_IPS="$ALLOWED_IPS"
PERSISTENT_KEEPALIVE="$PERSISTENT_KEEPALIVE"

echo $ADDRESS

# Write wg0.conf file
cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
PrivateKey = $PRIVATE_KEY
Address = $ADDRESS
PreUp = $PRE_UP_COMMAND

[Peer]
PublicKey = $PEER_PUBLIC_KEY
Endpoint = $ENDPOINT
AllowedIps = $ALLOWED_IPS
PersistentKeepalive = $PERSISTENT_KEEPALIVE
EOF

echo "wg0.conf generated successfully."
