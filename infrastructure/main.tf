terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "3.0.2-rc01"
    }
  }
}

provider "proxmox" {
  pm_api_url = "http://10.69.69.2:8006/api2/json"
  pm_tls_insecure = true # By default Proxmox Virtual Environment uses self-signed certificates.
}

