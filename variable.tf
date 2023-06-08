variable "proxmox_host" {
  description = "Information about de proxmox host api"
  type        = map(any)
  default = {
    pm_api_url  = "https://192.168.0.200:8006/api2/json"
    pm_user     = "root@pam"
    target_node = "balerion"
  }
}

variable "vmid" {
  description = "Starting ID for the VMs"
  default     = 230
}

variable "template" {
  description = "The base template for deploying Proxmox machines"
  default     = "tmp-ubuntu-jammy-9000"
}

variable "memory" {
  description = "Amount of memory to each node"
  type        = list(string)
  default     = ["3072", "4096"]
}

variable "hostname" {
  description = "VMs to be created"
  type        = list(string)
  # default     = ["tf-node000", "tf-node001", "tf-node002"]
  default     = ["tf-node000", "tf-node001"]
}

variable "rootfs_size" {
  default = "2G"
}

variable "ip_address" {
  description = "IPs of the VMs, respective to the hostname order"
  type        = list(string)
  # default     = ["192.168.0.230", "192.168.0.231", "192.168.0.232"]
  default     = ["192.168.0.230", "192.168.0.231"]
}

variable "ssh_keys" {
  description = "The ssh keys to login into machines"
  type        = map(any)
  default = {
    pub  = "~/.ssh/id_rsa.pub"
    priv = "~/.ssh/id_rsa"
  }
}

variable "user" {
  description = "User used to SSH into the machine and provision it"
  default     = "sysadmin" #default = ubuntu
}

variable "environment" {
  description = "Environment of the System"
  default     = "Testing" # Staging or Production
}

variable "domain_name" {
  type    = string
  default = "balerion.local.domain"
}