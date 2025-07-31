#!/usr/bin/env bash
# This script installs Ansible on all hosts defined in the Ansible inventory.

set -e

counter=0
# ssh into each host and install Ansible
# hmm it actually seems to run only on first host
while read -r host; do
    echo "Processing host: $host"
    if [ -z "$host" ]; then
        echo "Skipping empty host entry."
        continue
    fi
    counter=$((counter + 1))
    echo "Installing Ansible on $host..."
    ssh -oStrictHostKeyChecking=no -i "../infrastructure/ssh-keys/tf-cloud-init" "root@$host" "apt-get update && apt-get install -y ansible" < /dev/null
    if [ $? -eq 0 ]; then
        echo "Ansible installed successfully on $host."
    else
        echo "Failed to install Ansible on $host."
    fi
done < <(ansible-inventory -i ./inventories/inventory.ini --list | jq -r '
  ._meta.hostvars | to_entries[] | "\(.value.ansible_host // .value.ansible_ssh_host // .key)"' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}')

echo "Ansible installation completed on $counter hosts."