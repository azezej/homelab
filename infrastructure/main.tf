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
  pm_api_url      = var.pm_api_url
  pm_user         = var.pm_user
  pm_password     = var.pm_password
  pm_tls_insecure = var.pm_tls_insecure
}

resource "proxmox_vm_qemu" "k8s-cp" {
  for_each    = var.nodes
  target_node = each.value

  name = "k8s-cp-${each.value}"
  desc = "k8s-cp-${each.value} managed by OpenTofu"

  clone = var.templates[each.value] # use the template from the map

  cpu {
    cores   = var.cp_cpu_cores
    sockets = var.cp_cpu_sockets
  }

  memory = var.cp_memory * 1024
  agent  = var.cp_agent

  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"

  disks {
    ide {
      ide2 {
        cloudinit {
          storage = var.cp_cloudinit_storage
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          size      = var.cp_disk_size
          cache     = var.cp_disk_cache
          storage   = var.cp_disk_storage
          replicate = var.cp_replicate
        }
      }
    }
  }

  network {
    id     = var.cp_network_id
    model  = var.cp_network_model
    bridge = var.cp_network_bridge
  }

  boot = "order=scsi0"
  # make the ip dynamic from subnet 10s.69.69.10-20
  ipconfig0 = "ip=${var.subnet}.${each.key + 10}/${var.subnet_mask},gw=${var.gateway}"
  os_type   = "cloud-init"
  vmid      = 100 + each.key

  ciuser     = var.ssh_user
  cipassword = var.ssh_password

  sshkeys = var.ssh_keys

  serial {
    id   = 0
    type = "socket"
  }

  provisioner "remote-exec" {
    inline = ["echo ${var.ssh_password} | sudo -S -k hostnamectl set-hostname ${var.cp_hostname_prefix}-${each.value}"]

    connection {
      host        = self.ssh_host
      type        = "ssh"
      user        = var.ssh_user
      password    = var.ssh_password
      private_key = file("../tf-cloud-init")
    }
  }
}

resource "proxmox_vm_qemu" "k8s-worker" {
  # i wanna create one for all of my cluster nodes
  for_each    = var.nodes
  target_node = each.value

  name = "${var.worker_hostname_prefix}-${each.value}-${each.key}"
  desc = "${var.worker_hostname_prefix}-${each.value}-${each.key} managed by OpenTofu"

  ### Clone VM operation
  clone = var.templates[each.value]
  # note that cores, sockets and memory settings are not copied from the source VM template
  cpu {
    cores   = var.worker_cpu_cores
    sockets = var.worker_cpu_sockets
  }
  memory = var.worker_memory * 1024

  # Activate QEMU agent for this VM
  agent = var.worker_agent

  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"

  disks {
    ide {
      ide2 {
        cloudinit {
          storage = var.worker_cloudinit_storage
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          size      = var.worker_disk_size
          cache     = var.worker_disk_cache
          storage   = var.worker_disk_storage
          replicate = var.worker_replicate
        }
      }
    }
  }

  network {
    id     = var.worker_network_id
    model  = var.worker_network_model
    bridge = var.worker_network_bridge
  }

  boot = "order=scsi0"
  # make the ip dynamic from subnet 10.69.69.20-30
  ipconfig0 = "ip=${var.subnet}.${each.key + 20}/${var.subnet_mask},gw=${var.gateway}"
  os_type   = "cloud-init"
  vmid      = 200 + each.key

  ciuser     = var.ssh_user
  cipassword = var.ssh_password

  sshkeys = var.ssh_keys

  serial {
    id   = 0
    type = "socket"
  }

  provisioner "remote-exec" {
    inline = ["echo ${var.ssh_password} | sudo -S -k hostnamectl set-hostname ${var.worker_hostname_prefix}-${each.value}"]

    connection {
      host        = self.ssh_host
      type        = "ssh"
      user        = var.ssh_user
      password    = var.ssh_password
      private_key = file("../tf-cloud-init")
    }
  }
}

output "proxmox_cp_ips" {
  value = {
    for k, v in var.nodes :
    k => "${var.subnet}.${k + 10}"
  }
}

output "proxmox_worker_ips" {
  value = {
    for k, v in var.nodes :
    k => "${var.subnet}.${k + 20}"
  }
}