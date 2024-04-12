import os
from kubernetes import client, config
import subprocess

# Load Kubernetes configuration from default location
config.load_incluster_config()

# Kubernetes client
v1 = client.CoreV1Api()

# Label selector
label_selector = os.environ['SERVICELABEL']

# Get services with the specified label selector
services = v1.list_service_for_all_namespaces(label_selector=label_selector)

# Array to store IP addresses
ip_addresses = []

# Extract IP addresses from services
for service in services.items:
    ip_addresses.append(service.spec.cluster_ip)

# Function to check if an IP tables rule exists
def iptables_rule_exists(ip_address):
    try:
        subprocess.check_output(["iptables", "-t", "nat", "-C", "POSTROUTING", "-d", ip_address + "/32", "-j", "MASQUERADE"])
        return True
    except subprocess.CalledProcessError:
        return False

# Function to create IP tables rule
def create_iptables_rule(ip_address):
    subprocess.run(["iptables", "-t", "nat", "-A", "POSTROUTING", "-d", ip_address + "/32", "-j", "MASQUERADE"])

# Function to delete IP tables rule
def delete_iptables_rule(ip_address):
    subprocess.run(["iptables", "-t", "nat", "-D", "POSTROUTING", "-d", ip_address + "/32", "-j", "MASQUERADE"])

# Check existing rules and create/update rules for IP addresses
for ip_address in ip_addresses:
    if iptables_rule_exists(ip_address):
        print(f"Rule already exists for {ip_address}. Skipping.")
    else:
        print(f"Creating rule: iptables -t nat -D POSTROUTING -d {ip_address}/32 -j MASQUERADE.")
        create_iptables_rule(ip_address)

# Clean up existing rules for IP addresses not in the array
existing_rules_output = subprocess.check_output(["iptables", "-t", "nat", "-S", "POSTROUTING"]).decode("utf-8")
existing_rules = existing_rules_output.splitlines()
for rule in existing_rules:
    if "-d" in rule and "-j MASQUERADE" in rule:
        ip_address = rule.split()[rule.split().index("-d") + 1].split("/")[0]
        if ip_address not in ip_addresses:
            print(f"Deleting rule: iptables -t nat -D POSTROUTING -d {ip_address}/32 -j MASQUERADE.")
            delete_iptables_rule(ip_address)