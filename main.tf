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
  # http://kashyapc.wordpress.com/2011/10/15/virtio-balloon-in-action-with-native-linux-kvm-tool/
  # https://rwmj.wordpress.com/2010/07/17/virtio-balloon/
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

  /* ipconfig0 = "ip=${var.ips[count.index]}/24,gw=${cidrhost(format("%s/24", var.ips[count.index]), 1)}" */
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

  # Execute on Destroy time!
  provisioner "local-exec" {
    on_failure = continue
    when       = destroy
    command    = <<-EOT
    ssh-keygen -f '/home/william/.ssh/known_hosts' -R '${self.default_ipv4_address}' > /dev/null 2>&1 &&
    echo '' > servers.txt
    EOT
  }

  /*provisioner "local-exec" {
    command    = "sudo /bin/bash add_hosts.sh"
    #on_failure = continue
  }*/

  # Copies the myapp.conf file to /etc/myapp.conf
  /* provisioner "file" {
    source      = "instances.txt"
    destination = "/etc/hosts"
  } */

}
