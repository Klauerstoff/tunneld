#!/bin/sh

## Generate wg0.conf ##
# Define variables from environment variables
LOCAL_PRIVATE_KEY=$(yq e '.local.config.private-key' config.yaml)
LOCAL_PRIVATE_IP=$(yq e '.local.config.private-ip' config.yaml)
PEER_PUBLIC_KEY=$(yq e '.peer.config.public-key' config.yaml)
PEER_PUBLIC_IP=$(yq e '.peer.config.public-ip' config.yaml)
PEER_PRIVATE_IP=$(yq e '.peer.config.private-ip' config.yaml)
CONFIG_PERSISTENT_KEEPALIVE=$(yq e '.wg.config.persistent-keepalive' config.yaml)

# Write wg0.conf file
cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
PrivateKey = $LOCAL_PRIVATE_KEY

[Peer]
PublicKey = $PEER_PUBLIC_KEY
Endpoint = $PEER_PUBLIC_IP
AllowedIPs = $PEER_PRIVATE_IP
PersistentKeepalive = $CONFIG_PERSISTENT_KEEPALIVE
EOF
echo "wg0.conf generated successfully."

cat <<EOF > /etc/wireguard/wg0.address
$LOCAL_PRIVATE_IP
EOF
echo "wg0.address generated successfully."

#############################

## Add wireguard interface & route to private endpoint IP##

# delete `wg0` if it already exists
echo "Check if wireguard interface already exists."
if ip link show dev wg0 >/dev/null 2>&1; then
  ip link delete dev wg0
  echo "Wireguard interface deleted successfully."
fi
echo "No wireguard interface found."

# create and configure `wg0`
echo "Adding wireguard interface"
ip link add dev wg0 type wireguard
echo "Wireguard interface added successfully."
echo "Setting wireguard interface configuration"
wg setconf wg0 /etc/wireguard/wg0.conf
echo "Wireguard interface configuration set successfully."
echo "Adding wireguard interface address"
ip address add "$(cat /etc/wireguard/wg0.address)" dev wg0
echo "Wireguard interface address added successfully."
echo "Setting wireguard interface mtu"
ip link set mtu 1420 up dev wg0
echo "Wireguard interface mtu set successfully."
echo "Adding route to private endpoint IP"
ip route add $PEER_PRIVATE_IP dev wg0
echo "Route added successfully."

echo "Wireguard interface configured and route added successfully."

#############################