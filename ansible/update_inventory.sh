#!/bin/bash

# Configuration
VARS_FILE="./group_vars/all.yml"
PROXMOX_HOST=$(yq '.proxmox_host' "$VARS_FILE" | xargs)
API_USER=$(yq '.proxmox_api_user' "$VARS_FILE" | xargs)
API_PASS=$(yq '.proxmox_api_pass' "$VARS_FILE" | xargs)
INVENTORY_FILE=$(yq '.inventory_file' "$VARS_FILE" | xargs)

echo "Using Proxmox host: $PROXMOX_HOST"
echo "Using API user: $API_USER"
echo "Using inventory file: $INVENTORY_FILE"

declare -A groups

# Authenticate and get ticket
response=$(curl -sk -d "username=$API_USER&password=$API_PASS" "https://$PROXMOX_HOST:8006/api2/json/access/ticket")
TICKET=$(echo "$response" | jq -r '.data.ticket')
CSRF=$(echo "$response" | jq -r '.data.CSRFPreventionToken')
COOKIE="PVEAuthCookie=$TICKET"

[ -z "$TICKET" ] && echo "Failed to authenticate" && exit 1

# Fetch all VMs
vms_json=$(curl -sk -b "$COOKIE" \
  "https://$PROXMOX_HOST:8006/api2/json/cluster/resources?type=vm")
[ -z "$vms_json" ] && echo "Failed to fetch VM list" && exit 1

get_vm_tags() {
  local node=$1 vmid=$2
  curl -sk -b "$COOKIE" \
    "https://$PROXMOX_HOST:8006/api2/json/nodes/$node/qemu/$vmid/config" \
    | jq -r '.data.tags // ""'
}

get_vm_ip() {
  local node=$1 vmid=$2
  curl -sk -b "$COOKIE" \
    "https://$PROXMOX_HOST:8006/api2/json/nodes/$node/qemu/$vmid/agent/network-get-interfaces" 2>/dev/null \
    | jq -r '.[].["result"].[] | select(.["name"] == "eth1") | .["ip-addresses"].[] | select(.["ip-address-type"] == "ipv4").["ip-address"]'
}

get_vm_hostname() {
  local node=$1 vmid=$2
  curl -sk -b "$COOKIE" \
    "https://$PROXMOX_HOST:8006/api2/json/nodes/$node/qemu/$vmid/config" \
    | jq -r '.data.name // ""'
}

# Handle VMs
vm_count=$(echo "$vms_json" | jq '.data | length')
for ((i=0; i<vm_count; i++)); do
  vmid=$(echo "$vms_json" | jq -r ".data[$i].vmid")
  node=$(echo "$vms_json" | jq -r ".data[$i].node")
  status=$(echo "$vms_json" | jq -r ".data[$i].status")
  name=$(get_vm_hostname "$node" "$vmid")

  [ -z "$name" ] && echo "Warning: No name for VM $vmid on node $node" && continue
  [ -z "$status" ] && echo "Warning: No status for VM $vmid on node $node" && continue

  [ "$status" != "running" ] && continue

  tags=$(get_vm_tags "$node" "$vmid")
  ip=$(get_vm_ip "$node" "$vmid")
  [ -z "$ip" ] && ip=""

  IFS=';' read -ra tag_array <<< "${tags:-ungrouped}"
  for tag in "${tag_array[@]}"; do
    tag=$(echo "$tag" | xargs)
    groups["$tag"]+="$name ansible_host=$ip ansible_user=ansible ansible_port=22\n"
  done
done

# Add Proxmox nodes to a group
cluster_status_json=$(curl -sk -b "$COOKIE" "https://$PROXMOX_HOST:8006/api2/json/cluster/status")
[ -z "$cluster_status_json" ] && echo "Failed to fetch cluster status" && exit 1

nodes_count=$(echo "$cluster_status_json" | jq '[.data[] | select(.type=="node")] | length')

for ((i=0; i<nodes_count; i++)); do
  node_name=$(echo "$cluster_status_json" | jq -r "[.data[] | select(.type==\"node\")][$i].name")
  node_ip=$(echo "$cluster_status_json" | jq -r "[.data[] | select(.type==\"node\")][$i].ip")

  [ -z "$node_ip" ] && echo "Warning: No IP for node $node_name" && continue

  groups["proxmox_nodes"]+="$node_name ansible_host=$node_ip ansible_user=root ansible_port=22\n"
done


# echo "${groups[*]}" && echo "No groups found. Exiting." && exit 0 

# Write inventory
tmp_inv=$(mktemp)
for group in "${!groups[@]}"; do
  echo "[$group]" >> "$tmp_inv"
  echo -e "${groups[$group]}" >> "$tmp_inv"
  echo >> "$tmp_inv"
done

# Compare and update
if [ -f "$INVENTORY_FILE" ] && cmp -s "$INVENTORY_FILE" "$tmp_inv"; then
  echo "No changes detected. Inventory not updated."
  rm "$tmp_inv"
else
  mv "$tmp_inv" "$INVENTORY_FILE"
  echo "Inventory updated at $INVENTORY_FILE"
fi
