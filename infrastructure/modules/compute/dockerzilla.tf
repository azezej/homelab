# resource "proxmox_vm_qemu" "dockerzilla" {
#   target_node = var.proxmox_settings.nodes[2]

#   name = "${var.dockerzilla_settings.hostname_prefix}.${var.dockerzilla_settings.hostname_postfix}"
#   desc = "${var.dockerzilla_settings.hostname_prefix}.${var.dockerzilla_settings.hostname_postfix} managed by OpenTofu"
#   tags = var.dockerzilla_settings.tags

#   clone = var.proxmox_settings.template

#   cpu {
#     cores   = var.dockerzilla_settings.cpu_cores
#     sockets = var.dockerzilla_settings.cpu_sockets
#   }

#   memory = var.dockerzilla_settings.memory * 1024
#   agent  = var.dockerzilla_settings.agent

#   scsihw = "virtio-scsi-pci"

#   disks {
#     ide {
#       ide2 {
#         cloudinit {
#           storage = var.dockerzilla_settings.cloudinit_storage
#         }
#       }
#     }
#     scsi {
#       scsi0 {
#         disk {
#           size      = var.dockerzilla_settings.disk_size
#           cache     = var.dockerzilla_settings.disk_cache
#           storage   = var.dockerzilla_settings.disk_storage
#           replicate = var.dockerzilla_settings.replicate
#         }
#       }
#     }
#   }

#   network {
#     id     = var.network_settings.network_id
#     model  = var.network_settings.network_model
#     bridge = var.network_settings.network_bridge
#   }

#   os_network_config = <<EOF
#   auto lo
#   iface lo inet loopback

#   auto eth0
#   iface eth0 inet static
#       address ${var.network_settings.subnet}.11
#       netmask ${var.network_settings.netmask}
#       gateway ${var.network_settings.gateway}
#       dns-nameservers ${var.network_settings.dns01}
#       dns-nameservers ${var.network_settings.dns02}
#       dns-search ${var.dockerzilla_settings.hostname_postfix}
#   EOF

#   ipconfig1 = "ip=${var.network_settings.subnet}.11/${var.network_settings.cidr},gw=${var.network_settings.gateway}"

#   boot    = "order=scsi0"
#   os_type = var.dockerzilla_settings.os_type
#   vmid    = var.dockerzilla_settings.vmid

#   ciuser     = var.ssh_settings.ssh_user
#   cipassword = var.ssh_settings.ssh_password

#   sshkeys = var.ssh_settings.ssh_keys

#   serial {
#     id   = 0
#     type = "socket"
#   }

#   provisioner "remote-exec" {
#     inline = ["sudo hostnamectl set-hostname ${self.name}"]

#     connection {
#       host        = "${var.network_settings.subnet}.11"
#       type        = "ssh"
#       user        = var.ssh_settings.ssh_user
#       password    = var.ssh_settings.ssh_password
#       private_key = file("./ssh-keys/tf-cloud-init")
#     }
#   }
# }