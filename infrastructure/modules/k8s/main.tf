terraform {
  required_version = ">= 1.10.2"
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc01"
    }
  }
}

provider "proxmox" {
  pm_api_url      = var.proxmox_settings.pm_api_url
  pm_user         = var.proxmox_settings.pm_user
  pm_password     = var.proxmox_settings.pm_password
  pm_tls_insecure = var.proxmox_settings.pm_tls_insecure
}

resource "proxmox_vm_qemu" "k8s-cp" {
  for_each    = var.proxmox_settings.nodes
  target_node = each.value

  name = "${var.cp_settings.hostname_prefix}-${each.value}.${var.cp_settings.hostname_postfix}"
  desc = "${var.cp_settings.hostname_prefix}-${each.value}.${var.cp_settings.hostname_postfix} managed by OpenTofu"
  tags = var.cp_settings.tags

  clone = var.proxmox_settings.template

  cpu {
    cores   = var.cp_settings.cpu_cores
    sockets = var.cp_settings.cpu_sockets
  }

  memory = var.cp_settings.memory * 1024
  agent  = var.cp_settings.agent

  scsihw = "virtio-scsi-pci"

  disks {
    ide {
      ide2 {
        cloudinit {
          storage = var.cp_settings.cloudinit_storage
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          size      = var.cp_settings.disk_size
          cache     = var.cp_settings.disk_cache
          storage   = var.cp_settings.disk_storage
          replicate = var.cp_settings.replicate
        }
      }
    }
  }

  network {
    id     = var.network_settings.network_id
    model  = var.network_settings.network_model
    bridge = var.network_settings.network_bridge
  }

  boot = "order=scsi0"
  vmid = 300 + each.key

  os_network_config = <<EOF
  auto lo
  iface lo inet loopback

  auto eth0
  iface eth0 inet static
      address ${var.network_settings.subnet}.${each.key + 30}
      netmask ${var.network_settings.netmask}
      gateway ${var.network_settings.gateway}
      dns-nameservers ${var.network_settings.dns01}
      dns-nameservers ${var.network_settings.dns02}     
      dns-search ${var.cp_settings.hostname_postfix}
  EOF

  ipconfig1 = "ip=${var.network_settings.subnet}.${each.key + 30}/${var.network_settings.cidr},gw=${var.network_settings.gateway}"

  os_type = var.cp_settings.os_type

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
      host        = "${var.network_settings.subnet}.${each.key + 30}"
      type        = "ssh"
      user        = var.ssh_settings.ssh_user
      password    = var.ssh_settings.ssh_password
      private_key = file("./ssh-keys/tf-cloud-init")
    }
  }
}

resource "proxmox_vm_qemu" "k8s-worker" {
  for_each    = var.proxmox_settings.nodes
  target_node = each.value

  name = "${var.worker_settings.hostname_prefix}-${each.value}-${each.key}.${var.cp_settings.hostname_postfix}"
  desc = "${var.worker_settings.hostname_prefix}-${each.value}-${each.key}.${var.cp_settings.hostname_postfix} managed by OpenTofu"
  tags = var.worker_settings.tags

  clone = var.proxmox_settings.template

  cpu {
    cores   = var.worker_settings.cpu_cores
    sockets = var.worker_settings.cpu_sockets
  }
  memory = var.worker_settings.memory * 1024
  agent  = var.worker_settings.agent

  scsihw = "virtio-scsi-pci"

  disks {
    ide {
      ide2 {
        cloudinit {
          storage = var.worker_settings.cloudinit_storage
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          size      = var.worker_settings.disk_size
          cache     = var.worker_settings.disk_cache
          storage   = var.worker_settings.disk_storage
          replicate = var.worker_settings.replicate
        }
      }
    }
  }

  network {
    id     = var.network_settings.network_id
    model  = var.network_settings.network_model
    bridge = var.network_settings.network_bridge
  }

  boot = "order=scsi0"

  os_network_config = <<EOF
  auto lo
  iface lo inet loopback

  auto eth0
  iface eth0 inet static
      address ${var.network_settings.subnet}.${each.key + 40}
      netmask ${var.network_settings.netmask}
      gateway ${var.network_settings.gateway}
      dns-nameservers ${var.network_settings.dns01}
      dns-nameservers ${var.network_settings.dns02}
      dns-search ${var.worker_settings.hostname_postfix}
  EOF

  ipconfig1 = "ip=${var.network_settings.subnet}.${each.key + 40}/${var.network_settings.cidr},gw=${var.network_settings.gateway}"

  os_type = var.worker_settings.os_type
  vmid    = 310 + each.key

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
      host        = "${var.network_settings.subnet}.${each.key + 40}"
      type        = "ssh"
      user        = var.ssh_settings.ssh_user
      password    = var.ssh_settings.ssh_password
      private_key = file("./ssh-keys/tf-cloud-init")
    }
  }
}
