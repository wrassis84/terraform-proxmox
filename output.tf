output "vm_ipv4_addresses" {
  value = {
    for instance in proxmox_vm_qemu.virtual_machines :
    instance.name => instance.default_ipv4_address
  }
}

output "name" {
  value = formatlist("%s.%s", proxmox_vm_qemu.virtual_machines.*.name, var.domain_name)
}

output "env" {
  value = var.environment
}
