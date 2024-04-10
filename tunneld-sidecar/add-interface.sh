#!/bin/sh

# delete `wg0` if it already exists
if ip link show dev wg0 >/dev/null 2>&1; then
  ip link delete dev wg0
fi

# create and configure `wg0`
ip link add dev wg0 type wireguard
wg setconf wg0 /etc/wireguard/wg0.conf
ip address add "$(cat /etc/wireguard/wg0.address)" dev wg0
ip link set mtu 1420 up dev wg0
