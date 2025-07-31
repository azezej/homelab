terraform {
  required_version = ">= 1.10.2"
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc01"
    }
  }
}

module "k8s" {
  source = "./modules/k8s"

  proxmox_settings = var.proxmox_settings
  ssh_settings     = var.ssh_settings
  network_settings = var.network_settings
  cp_settings      = var.cp_settings
  worker_settings  = var.worker_settings

}

module "compute" {
  source = "./modules/compute"

  proxmox_settings = var.proxmox_settings
  ssh_settings     = var.ssh_settings
  network_settings = var.network_settings

  ns01_settings        = var.ns01_settings
  ns02_settings        = var.ns02_settings
  dockerzilla_settings = var.dockerzilla_settings
}

module "lxc" {
  source = "./modules/lxc"
}

