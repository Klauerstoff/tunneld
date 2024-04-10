#!/bin/sh

## Generate wg0.conf ##
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

#############################

## Add wireguard interface & route to private endpoint IP##

# delete `wg0` if it already exists
if ip link show dev wg0 >/dev/null 2>&1; then
  ip link delete dev wg0
fi

# create and configure `wg0`
ip link add dev wg0 type wireguard
wg setconf wg0 /etc/wireguard/wg0.conf
ip address add "$(cat /etc/wireguard/wg0.address)" dev wg0
ip link set mtu 1420 up dev wg0

ip route add $ENDPOINT_PRIVATE dev wg0

#############################

