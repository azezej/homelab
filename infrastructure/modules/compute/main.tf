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