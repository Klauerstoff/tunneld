#!/bin/sh

set -e

## Generate wg0.conf ##
# Define variables from environment variables
LOCAL_PRIVATE_KEY=$(yq e '.local.config.private-key' /config/config.yaml)
LOCAL_PRIVATE_IP=$(yq e '.local.config.private-ip' /config/config.yaml)
PEER_PUBLIC_KEY=$(yq e '.peer.config.public-key' /config/config.yaml)
PEER_PUBLIC_IP=$(yq e '.peer.config.public-ip' /config/config.yaml)
PEER_PRIVATE_IP=$(yq e '.peer.config.private-ip' /config/config.yaml)
CONFIG_PERSISTENT_KEEPALIVE=$(yq e '.wg.config.persistentKeepalive' /config/config.yaml)

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
if ! ip link add dev wg0 type wireguard; then
  echo "Failed to add wireguard interface"
  echo "Error: $?"
  exit 1
fi
echo "Wireguard interface added successfully."

echo "Setting wireguard interface configuration"
if ! wg setconf wg0 /etc/wireguard/wg0.conf; then
  echo "Failed to set wireguard interface configuration"
  echo "Error: $?"
  exit 1
fi
echo "Wireguard interface configuration set successfully."

echo "Adding wireguard interface address"
if ! ip address add "$(cat /etc/wireguard/wg0.address)" dev wg0; then
  echo "Failed to add wireguard interface address"
  echo "Error: $?"
  exit 1
fi
echo "Wireguard interface address added successfully."

echo "Setting wireguard interface mtu"
if ! ip link set mtu 1420 up dev wg0; then
  echo "Failed to set wireguard interface mtu"
  echo "Error: $?"
  exit 1
fi
echo "Wireguard interface mtu set successfully."

echo "Adding route to private endpoint IP"
PEER_PRIVATE_IP_NOCIDR=${PEER_PRIVATE_IP%/*}
if ! ip route add $PEER_PRIVATE_IP_NOCIDR dev wg0; then
  echo "Failed to add route to private endpoint IP"
  echo "Error: $?"
  exit 1
fi
echo "Route added successfully."

echo "Wireguard interface configured and route added successfully."