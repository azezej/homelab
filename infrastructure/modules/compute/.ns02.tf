resource "proxmox_vm_qemu" "ns02" {
  target_node = var.proxmox_settings.nodes[2]

  name = "${var.ns02_settings.hostname_prefix}.${var.ns02_settings.hostname_postfix}"
  desc = "${var.ns02_settings.hostname_prefix}.${var.ns02_settings.hostname_postfix} managed by OpenTofu"
  tags = var.ns02_settings.tags

  clone = var.proxmox_settings.template

  cpu {
    cores   = var.ns02_settings.cpu_cores
    sockets = var.ns02_settings.cpu_sockets
  }

  memory = var.ns02_settings.memory * 1024
  agent  = var.ns02_settings.agent

  scsihw = "virtio-scsi-pci"

  disks {
    ide {
      ide2 {
        cloudinit {
          storage = var.ns02_settings.cloudinit_storage
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          size      = var.ns02_settings.disk_size
          cache     = var.ns02_settings.disk_cache
          storage   = var.ns02_settings.disk_storage
          replicate = var.ns02_settings.replicate
        }
      }
    }
  }

  network {
    id     = var.network_settings.network_id
    model  = var.network_settings.network_model
    bridge = var.network_settings.network_bridge
  }

  os_network_config = <<EOF
  auto lo
  iface lo inet loopback

  auto eth0
  iface eth0 inet static
      address ${var.network_settings.subnet}.6
      netmask ${var.network_settings.netmask}
      gateway ${var.network_settings.gateway}
      dns-nameservers ${var.network_settings.dns01}
      dns-nameservers ${var.network_settings.dns02}
      dns-search ${var.ns02_settings.hostname_postfix}
  EOF

  ipconfig1 = "ip=${var.network_settings.subnet}.6/${var.network_settings.cidr},gw=${var.network_settings.gateway}"

  boot    = "order=scsi0"
  os_type = var.ns02_settings.os_type
  vmid    = var.ns02_settings.vmid

  ciuser     = var.ssh_settings.ssh_user
  cipassword = var.ssh_settings.ssh_password

  sshkeys = var.ssh_settings.ssh_keys

  serial {
    id   = 0
    type = "socket"
  }

  provisioner "remote-exec" {
    inline = ["sudo hostnamectl set-hostname ${self.name}"]

    connection {
      host        = "${var.network_settings.subnet}.6"
      type        = "ssh"
      user        = var.ssh_settings.ssh_user
      password    = var.ssh_settings.ssh_password
      private_key = file("./ssh-keys/tf-cloud-init")
    }
  }
}