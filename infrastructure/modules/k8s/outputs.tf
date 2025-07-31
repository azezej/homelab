output "proxmox_cp_ips" {
  value = {
    for k, v in var.proxmox_settings.nodes :
    k => "${var.network_settings.subnet}.${k + 10}"
  }
}

output "proxmox_worker_ips" {
  value = {
    for k, v in var.proxmox_settings.nodes :
    k => "${var.network_settings.subnet}.${k + 20}"
  }
}