provider "proxmox" {

  pm_api_url      = var.proxmox_host["pm_api_url"]
  pm_user         = var.proxmox_host["pm_user"]
  pm_tls_insecure = true

  pm_log_enable = true
  pm_log_file   = "terraform-plugin-proxmox.log"
  pm_debug      = true
  pm_log_levels = {
    _default    = "debug"
    _capturelog = ""
  }

}

resource "proxmox_vm_qemu" "virtual_machines" {

  count       = length(var.hostnames)
  name        = var.hostnames[count.index]
  target_node = var.proxmox_host["target_node"]
  vmid        = var.vmid + count.index
  full_clone  = true
  clone       = var.template

  cores   = 2
  sockets = 1
  vcpus   = 2
  memory  = 2048
  # "balloon" defines the minimum memory for VM. More info:
  # https://tinyurl.com/kashyapc
  # https://tinyurl.com/virtio-balloon
  balloon  = 2048
  boot     = "c"
  bootdisk = "virtio0"
  scsihw   = "virtio-scsi-pci"

  onboot  = true
  agent   = 1
  cpu     = "kvm64"
  numa    = true
  hotplug = "network,disk,cpu,memory"

  network {
    bridge = "vmbr0"
    model  = "virtio"
  }

  ipconfig0 = "ip=${var.ip_address[count.index]}/24,gw=192.168.0.1"

  disk {
    # disk 001
    type    = "scsi"
    storage = "local"
    ssd     = 1
    size    = "25G"
  }

  disk {
    # disk 002
    type    = "scsi"
    storage = "local"
    ssd     = 1
    size    = "25G"
  }

  os_type = "cloud-init"

  provisioner "local-exec" {
    on_failure = continue
    when       = create
    command    = "echo '${self.name} ${self.default_ipv4_address}' >> servers.txt"
  }
}
