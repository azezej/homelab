#!/usr/bin/env bash

# run on Proxmox VE host to prepare an Ubuntu template for use with Terraform and Ansible
# Source a file containing a list of node hostnames or IPs and SSH into each to run multiple commands
NODES_FILE="../ansible/inventories/inventory.ini"
if [[ -f "$NODES_FILE" ]]; then
    while read -r node; do
        [[ -z "$node" || "$node" =~ ^# ]] && continue
        echo "Connecting to $node..."
        ssh "$node" -i "../infrastructure/ssh-keys/tf-cloud-init" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "
            sudo apt update -y
            sudo apt install -y libguestfs-tools
            sudo apt install -y qemu-utils
            sudo systemctl enable --now qemu-guest-agent
            wget https://cloud-images.ubuntu.com/daily/server/server/noble/current/noble-server-cloudimg-amd64.img 

            echo "kurwa" > password_root.txt
            echo "ansible" > password_ansible.txt
            echo "blazej" > password_blazej.txt

            # Install qemu-guest-agent on the image. Additional packages can be specified by separating with a comma.
            virt-customize -a jammy-server-cloudimg-amd64.img --install qemu-guest-agent
            # Read and set root user password from file.
            virt-customize -a jammy-server-cloudimg-amd64.img --root-password file:password_root.txt
            # Create an additional user.
            virt-customize -a jammy-server-cloudimg-amd64.img --run-command "useradd -m -s /bin/bash ansible"
            virt-customize -a jammy-server-cloudimg-amd64.img --run-command "useradd -m -s /bin/bash blazej"

            # Set password for that user.
            virt-customize -a jammy-server-cloudimg-amd64.img --password myuser:file:password_ansible.txt
            virt-customize -a jammy-server-cloudimg-amd64.img --password myuser:file:password_blazej.txt
            # Delete temporary password files safely.
            virt-customize -a jammy-server-cloudimg-amd64.img --install python3 
            virt-customize -a jammy-server-cloudimg-amd64.img --install python3-netaddr
            virt-customize -a jammy-server-cloudimg-amd64.img --install ansible

            # Finally, update all packages in the image.
            virt-customize -a jammy-server-cloudimg-amd64.img --update

            # Next, we create a Proxmox VM template.
            # Change values for your bridge and storage and change defaults to your liking.
            qm create 777 --name "ubuntu-24.04-template" --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
            qm importdisk 777 jammy-server-cloudimg-amd64.img vmstore
            qm set 777 --scsihw virtio-scsi-pci --scsi0 vmstore:vm-777-disk-0
            qm set 777 --boot c --bootdisk scsi0
            qm set 777 --ide2 vmstore:cloudinit
            qm set 777 --serial0 socket --vga serial0
            qm set 777 --agent enabled=1
            qm template 777
        "
    done < "$NODES_FILE"
fi

# Now we can create new VMs by cloning this template or reference it with Terraform Proxmox etc.
# Login with SSH only possible with user "ubuntu" and SSH keys specified in cloudinit image.
