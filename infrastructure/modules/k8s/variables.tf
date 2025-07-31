# -------------------------
# General Proxmox Variables
# -------------------------

variable "proxmox_settings" {
  description = "Proxmox settings for the infrastructure"
  type = object({
    pm_api_url      = string
    pm_user         = string
    pm_password     = string
    pm_tls_insecure = bool

    nodes    = map(string)
    template = string
  })
}

# -------------------------
# SSH Variables
# -------------------------

variable "ssh_settings" {
  description = "SSH settings for control plane nodes"
  type = object({
    ssh_user     = string
    ssh_password = string
    ssh_keys     = string
  })
}

# -------------------------
# Network Variables
# -------------------------

variable "network_settings" {
  description = "Network settings for control plane nodes"
  type = object({
    subnet  = string
    cidr    = string
    netmask = string
    gateway = string
    dns01   = string
    dns02   = string

    network_id     = string
    network_model  = string
    network_bridge = string
  })
}

# -------------------------
# Control Plane Variables
# -------------------------

variable "cp_settings" {
  description = "Settings for control plane nodes"
  type = object({
    hostname_prefix   = string
    hostname_postfix  = optional(string, "")
    tags              = optional(string, "")
    cpu_cores         = number
    cpu_sockets       = number
    memory            = number
    agent             = number
    cloudinit_storage = string
    disk_size         = number
    disk_cache        = string
    disk_storage      = string
    replicate         = bool
    os_type           = string
    preprovision      = bool
  })
}

# -------------------------
# Worker Variables
# -------------------------

variable "worker_settings" {
  description = "Settings for worker nodes"
  type = object({
    hostname_prefix   = string
    hostname_postfix  = optional(string, "")
    tags              = optional(string, "")
    cpu_cores         = number
    cpu_sockets       = number
    memory            = number
    agent             = number
    cloudinit_storage = string
    disk_size         = number
    disk_cache        = string
    disk_storage      = string
    replicate         = bool
    os_type           = string
    preprovision      = bool
  })
}