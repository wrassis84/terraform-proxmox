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

  count       = length(var.hostname)
  name        = var.hostname[count.index]
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
  # remote-exec example-> ginigangadharan/terraform-iac-usecases: l1nq.com/nYz5T
  # TF_VAR doc -> l1nq.com/VgUte
  # Use Input Variables -> l1nq.com/0H2LZ
  # multiple commands in local-exec provisioner -> l1nk.dev/R37Sr
  # This build the inventory file in inventory.yaml.
    on_failure = continue
    when       = create
    command    = <<EOT
      echo [docker_swarm_manager] > $TF_VAR_inventory;
      echo ${var.hostname[0]} ansible_host=${var.ip_address[0]} >> $TF_VAR_inventory;
      echo '' >> $TF_VAR_inventory;
      echo [docker_swarm_worker] >> $TF_VAR_inventory;
      echo ${var.hostname[1]} ansible_host=${var.ip_address[1]} >> $TF_VAR_inventory;
      echo ${var.hostname[2]} ansible_host=${var.ip_address[2]} >> $TF_VAR_inventory;
      echo '' >> $TF_VAR_inventory;
      echo [all:vars] >> $TF_VAR_inventory;
      echo ansible_python_interpreter=/usr/bin/python3 >> $TF_VAR_inventory
    EOT
  }
  
  provisioner "local-exec" {
    # Clean the inventory file at each destroy time.
    on_failure = continue
    when       = destroy
    command    = "echo '' > $TF_VAR_inventory"
  }
}