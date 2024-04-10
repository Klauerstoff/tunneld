#!/bin/sh

# Define variables from environment variables
PRIVATE_KEY="$PRIVATE_KEY"
ADDRESS="$ADDRESS"
PEER_PUBLIC_KEY="$PEER_PUBLIC_KEY"
ENDPOINT="$ENDPOINT"
ALLOWED_IPS="$ALLOWED_IPS"
PERSISTENT_KEEPALIVE="$PERSISTENT_KEEPALIVE"

# Write wg0.conf file
cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
PrivateKey = $PRIVATE_KEY

[Peer]
PublicKey = $PEER_PUBLIC_KEY
Endpoint = $ENDPOINT
AllowedIPs = $ALLOWED_IPS
PersistentKeepalive = $PERSISTENT_KEEPALIVE
EOF
echo "wg0.conf generated successfully."

cat <<EOF > /etc/wireguard/wg0.address
$ADDRESS
EOF
echo "wg0.address generated successfully."
