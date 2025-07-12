# -------------------------
# General Proxmox Variables
# -------------------------
variable "pm_api_url" {
  description = "Proxmox API URL"
  type        = string
  default     = "https://10.69.69.2:8006/api2/json"
}

variable "pm_user" {
  description = "Proxmox username"
  type        = string
  default     = "terraform-prov@pam"
}

variable "pm_password" {
  description = "Proxmox password"
  type        = string
  sensitive   = true
}

variable "pm_tls_insecure" {
  description = "Proxmox tls trusted?"
  type        = bool
}

variable "nodes" {
  description = "List of Proxmox nodes to deploy the VMs on"
  type        = map(string)
  default = {
    "1" = "atena"
    "2" = "zeus"
    "3" = "afrodyta"
  }
}

variable "templates" {
  description = "List of Proxmox templates to use for cloning VMs"
  type        = map(string)
  default = ({
    "atena"    = "888"
    "zeus"     = "999"
    "afrodyta" = "777"
  })
}

# -------------------------
# SSH Variables
# -------------------------
variable "ssh_user" {
  description = "ssh username"
  type        = string
  default     = "blazej"
}

variable "ssh_password" {
  description = "ssh password"
  type        = string
  sensitive   = true
}

variable "ssh_host" {
  description = "SSH host for remote execution"
  type        = string
  default     = "localhost"
}

variable "ssh_port" {
  description = "SSH port for remote execution"
  type        = number
  default     = 22
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key for remote execution"
  type        = string
  default     = "../tf-cloud-init"
}

variable "ssh_keys" {
  description = "SSH public keys for remote execution"
  type        = string
  default     = ""
}

# -------------------------
# Network Variables
# -------------------------
variable "subnet" {
  description = "Subnet for control plane nodes"
  type        = string
  default     = "10.69.69"
}

variable "subnet_mask" {
  description = "Subnet mask for control plane nodes"
  type        = string
  default     = "24"
}

variable "gateway" {
  description = "Gateway for control plane nodes"
  type        = string
  default     = "10.69.69.1"
}

# -------------------------
# Control Plane Variables
# -------------------------
variable "cp_hostname_prefix" {
  description = "Hostname prefix for control plane nodes"
  type        = string
  default     = "k8s-cp"
}

variable "cp_cpu_cores" {
  description = "Number of CPU cores for control plane nodes"
  type        = number
  default     = 2
}

variable "cp_cpu_sockets" {
  description = "Number of CPU sockets for control plane nodes"
  type        = number
  default     = 1
}

variable "cp_memory" {
  description = "Memory in GB for control plane nodes"
  type        = number
  default     = 4
}

variable "cp_agent" {
  description = "Enable QEMU agent for control plane nodes"
  type        = number
  default     = 1 // 0 = false, 1 = true
}

variable "cp_cloudinit_storage" {
  description = "Storage for cloud-init data for control plane nodes"
  type        = string
  default     = "local-lvm"
}

variable "cp_disk_size" {
  description = "Disk size in GB for control plane nodes"
  type        = number
  default     = 32
}

variable "cp_disk_cache" {
  description = "Disk cache mode for control plane nodes"
  type        = string
  default     = "writeback"
}

variable "cp_disk_storage" {
  description = "Storage for disks of control plane nodes"
  type        = string
  default     = "local-lvm"
}

variable "cp_replicate" {
  description = "Enable disk replication for control plane nodes"
  type        = bool
  default     = false
}

variable "cp_network_id" {
  description = "Network ID for control plane nodes"
  type        = number
  default     = 0
}

variable "cp_network_model" {
  description = "Network model for control plane nodes"
  type        = string
  default     = "virtio"
}

variable "cp_network_bridge" {
  description = "Network bridge for control plane nodes"
  type        = string
  default     = "vmbr0"
}

# -------------------------
# Worker Variables
# -------------------------
variable "worker_hostname_prefix" {
  description = "Hostname prefix for worker nodes"
  type        = string
  default     = "k8s-worker"
}

variable "worker_cpu_cores" {
  description = "Number of CPU cores for worker nodes"
  type        = number
  default     = 2
}

variable "worker_cpu_sockets" {
  description = "Number of CPU sockets for worker nodes"
  type        = number
  default     = 1
}

variable "worker_memory" {
  description = "Memory in GB for worker nodes"
  type        = number
  default     = 4
}

variable "worker_agent" {
  description = "Enable QEMU agent for worker nodes"
  type        = number
  default     = 0 // 0 = false, 1 = true
}

variable "worker_cloudinit_storage" {
  description = "Storage for cloud-init data for worker nodes"
  type        = string
  default     = "local-lvm"
}

variable "worker_disk_size" {
  description = "Disk size in GB for worker nodes"
  type        = number
  default     = 32
}

variable "worker_disk_cache" {
  description = "Disk cache mode for worker nodes"
  type        = string
  default     = "writeback"
}

variable "worker_disk_storage" {
  description = "Storage for disks of worker nodes"
  type        = string
  default     = "local-lvm"
}

variable "worker_replicate" {
  description = "Enable disk replication for worker nodes"
  type        = bool
  default     = false
}

variable "worker_network_id" {
  description = "Network ID for worker nodes"
  type        = number
  default     = 0
}

variable "worker_network_model" {
  description = "Network model for worker nodes"
  type        = string
  default     = "virtio"
}

variable "worker_network_bridge" {
  description = "Network bridge for worker nodes"
  type        = string
  default     = "vmbr0"
}
