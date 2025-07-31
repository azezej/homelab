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
  default = {
    pm_api_url      = "https://10.69.69.2:8006/api2/json"
    pm_user         = "terraform-prov@pam"
    pm_password     = "password"
    pm_tls_insecure = true

    nodes = {
      "1" = "atena"
      "2" = "zeus"
      "3" = "afrodyta"
    }

    template = "ubuntu-24.04-template"
  }
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
  default = {
    ssh_user     = "root"
    ssh_password = "password"
    ssh_keys     = ""
  }
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
  default = {
    subnet  = "10.69.69"
    cidr    = "24"
    netmask = "255.255.255.0"
    gateway = "10.69.69.1"
    dns01   = "10.69.69.10"
    dns02   = "10.69.69.10"

    network_id     = "1"
    network_model  = "virtio"
    network_bridge = "vmbr0"
  }
}

# -------------------------
# K8S Control Plane Variables
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
  default = {
    hostname_prefix   = "k8s-cp"
    hostname_postfix  = "katedra.kys"
    cpu_cores         = 2
    cpu_sockets       = 1
    memory            = 4
    agent             = 1
    cloudinit_storage = "local-lvm"
    disk_size         = 32
    disk_cache        = "writeback"
    disk_storage      = "local-lvm"
    replicate         = false
    os_type           = "ubuntu"
    preprovision      = true
  }
}

# -------------------------
# K8S Worker Variables
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
  default = {
    hostname_prefix   = "k8s-worker"
    hostname_postfix  = "katedra.kys"
    cpu_cores         = 2
    cpu_sockets       = 1
    memory            = 4
    agent             = 0
    cloudinit_storage = "local-lvm"
    disk_size         = 32
    disk_cache        = "writeback"
    disk_storage      = "local-lvm"
    replicate         = false
    os_type           = "ubuntu"
    preprovision      = true
  }
}

# -------------------------
# dns Variables
# -------------------------

variable "ns01_settings" {
  description = "Settings for dns node"
  type = object({
    hostname_prefix   = string
    hostname_postfix  = optional(string, "")
    tags              = optional(string, "")
    vmid              = number
    cpu_cores         = number
    cpu_sockets       = number
    memory            = number
    agent             = number
    cloudinit_storage = string
    disk_size         = string
    disk_cache        = string
    disk_storage      = string
    replicate         = bool
    os_type           = string
    preprovision      = bool
  })
  default = {
    hostname_prefix   = "dns"
    hostname_postfix  = "katedra.kys"
    vmid              = 100
    cidr              = 10
    cpu_cores         = 1
    cpu_sockets       = 1
    memory            = 2
    agent             = 1
    cloudinit_storage = "local-lvm"
    disk_size         = "8G"
    disk_cache        = "writeback"
    disk_storage      = "local-lvm"
    replicate         = false
    os_type           = "ubuntu"
    preprovision      = true
  }
}

variable "ns02_settings" {
  description = "Settings for dns node"
  type = object({
    hostname_prefix   = string
    hostname_postfix  = optional(string, "")
    tags              = optional(string, "")
    vmid              = number
    cpu_cores         = number
    cpu_sockets       = number
    memory            = number
    agent             = number
    cloudinit_storage = string
    disk_size         = string
    disk_cache        = string
    disk_storage      = string
    replicate         = bool
    os_type           = string
    preprovision      = bool
  })
  default = {
    hostname_prefix   = "dns"
    hostname_postfix  = "katedra.kys"
    vmid              = 100
    cidr              = 10
    cpu_cores         = 1
    cpu_sockets       = 1
    memory            = 2
    agent             = 1
    cloudinit_storage = "local-lvm"
    disk_size         = "8G"
    disk_cache        = "writeback"
    disk_storage      = "local-lvm"
    replicate         = false
    os_type           = "ubuntu"
    preprovision      = true
  }
}

variable "dockerzilla_settings" {
  description = "Settings for dockerzilla node"
  type = object({
    hostname_prefix   = string
    hostname_postfix  = optional(string, "")
    tags              = optional(string, "")
    vmid              = number
    cpu_cores         = number
    cpu_sockets       = number
    memory            = number
    agent             = number
    cloudinit_storage = string
    disk_size         = string
    disk_cache        = string
    disk_storage      = string
    replicate         = bool
    os_type           = string
    preprovision      = bool
  })
  default = {
    hostname_prefix   = "dockerzilla"
    hostname_postfix  = "katedra.kys"
    vmid              = 100
    cidr              = 10
    cpu_cores         = 1
    cpu_sockets       = 1
    memory            = 2
    agent             = 1
    cloudinit_storage = "local-lvm"
    disk_size         = "8G"
    disk_cache        = "writeback"
    disk_storage      = "local-lvm"
    replicate         = false
    os_type           = "ubuntu"
    preprovision      = true
  }
}
