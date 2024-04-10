#!/bin/sh

iptables -t nat -A POSTROUTING -d $DESTINATION -j MASQUERADE
