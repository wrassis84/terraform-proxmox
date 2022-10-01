# This file: proxmox_template.sh
# This script must be executed on Proxmox host and image used must be in the same directory

# Variables/Functions definitions:
url="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
image="jammy-server-cloudimg-amd65.img"
template_id="9100"
vm_id="9100"
memory_size="1024"
vm_name="tmp-ubuntu-jammy-9100"
networ_config="virtio,bridge=vmbr0"


echo "Checking necessary files..."
apt update -y && sudo apt install libguestfs-tools -y
virt-customize -a $image --install qemu-guest-agent --truncate /etc/machine-id

echo "Creating Proxmox machine using ubuntu cloud-image..."
qm create $vm_id --memory $memory_size --name $vm_name --net $networ_config
qm importdisk $vm_id $image local
qm set $vm_id --scsihw virtio-scsi-pci --scsi0 local:$vm_id/vm-$vm_id-disk-0.raw
qm set $vm_id --ide2 local:cloudinit
qm set $vm_id --boot c --bootdisk scsi0
qm set $vm_id --serial0 socket --vga serial0
qm set $vm_id --agent enabled=1
#qm set $vm_id --sshkey /tmp/id_rsa.pub
#qm set $vm_id --ciuser sysadmin
qm set $vm_id --machine q35
qm template $vm_id
