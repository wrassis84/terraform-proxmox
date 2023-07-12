# terraform-proxmox
Este repositório contém arquivos e instruções para provisionar máquinas virtuais
no virtualizador [**`Proxmox`**](https://www.proxmox.com/en/) utilizando a ferramenta de `IaC` [**`Terraform`**](https://www.terraform.io/).

Trata-se de um projeto de *homelab* que desenvolvi para praticar o uso de ferramentas *DevOps* como o [**`Terraform`**](https://www.terraform.io/), [**`Proxmox`**](https://www.proxmox.com/en/) e [**`Ansible`**](https://www.ansible.com/).

### Tópicos:
- [terraform-proxmox](#terraform-proxmox)
    - [Tópicos:](#tópicos)
    - [Instalação do `Proxmox`:](#instalação-do-proxmox)
    - [Criação do template da máquina virtual:](#criação-do-template-da-máquina-virtual)
    - [Instalação e configuração do `Terraform`:](#instalação-e-configuração-do-terraform)

### Instalação do `Proxmox`:
Primeiramente, será necessário instalar o `Proxmox` no seu hardware. Eu utilizei um *laptop* com 8 GB de RAM, processador CORE I7 (5ª geração) e disco SSD Sata com 500GB de espaço. O `Proxmox` não é muito exigente em termos de hardware, mas tenha em mente que a capacidade do hardware utilizado vai influenciar no desempenho do próprio virtualizador e na quantidade de máquinas virtuais que ele poderá executar.

Em razão de haver muito material disponível na Web sobre a instalação do `Proxmox` e isso ser um processo relativamente simples, não abordarei sua instalação.

### Criação do template da máquina virtual:

Será necessário criar um template de máquina virtual nos moldes do [**`cloud-init`**](https://cloud-init.io/). Para a criação do template que utilizaremos, pode-se visitar a página [Cloud-init no Proxmox Virtual Environment 6](https://golesuite.com/br/blog/blog-post-2/). Embora no site tenha-se criado o template utilizando a versão 6 do **`Proxmox`**, eu utilizei na versão 7 sem problemas. Eu utilizei as configurações do site acima e algumas customizações colhidas na web após sofrer com vários problemas! 🤯

Eu utilizei a [imagem do Ubuntu 22.04](https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img).
> Acredito que deve funcionar para imagens mais atuais sem problemas!

Acesse seu servidor `Proxmox` - via `SSH` - faça o *login* como root e execute os seguintes comandos:

`wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img`

A partir do seu Desktop, copie os arquivos necessários da sua máquina para o servidor Proxmox:
> No primeiro comando, temos o arquivo de configuração do editor **`VIM`** e no primeiro comando temos o arquivo de configurações do Shell **`bash`**.
```
scp ~/.vimrc root@192.168.0.200:/tmp
scp ~/.bashrc root@192.168.0.200:/tmp
```
Agora, copie a sua chave `SSH` pública para o servidor Proxmox, para que possamos adicionar esta chave no template do cloud-init:
```
scp ~/.ssh/id_rsa.pub root@192.168.0.200:/tmp
```

Volte ao console do servidor `Proxmox` e, após baixar a imagem, atualize a lista de pacotes do sistema, instale as ferramentas **`libguestfs-tools`** e, após instale o **`qemu-guest-agent`** e os demais pacotes na imagem baixada conforme a seguir:

```
apt update -y && apt install libguestfs-tools -y
virt-customize -a jammy-server-cloudimg-amd64.img --install qemu-guest-agent --truncate /etc/machine-id
virt-customize -a jammy-server-cloudimg-amd64.img --install vim
virt-customize -a jammy-server-cloudimg-amd64.img --install bash-completion
virt-customize -a jammy-server-cloudimg-amd64.img --install wget
virt-customize -a jammy-server-cloudimg-amd64.img --install curl
virt-customize -a jammy-server-cloudimg-amd64.img --install unzip
virt-customize -a jammy-server-cloudimg-amd64.img --install git
```
> Nos comandos acima, o parâmetro "--truncate /etc/machine-id" foi contribuição do [Mateus Muller](https://mateusmuller.me/).

Agora crie uma máquina virtual com base na imagem baixada:
```
qm create <new_vm_id> <memory>  --name <vm_name> --net <networ_config>
qm create 9000 --memory 1024 --name tmp-ubuntu-jammy-9000 --net0 virtio,bridge=vmbr0
```
Agora veja em **`/etc/pve/storage.cfg`** qual é a storage que você deseja guardar essa imagem. Neste caso, vamos utilizar a storage local:
```
qm importdisk 9000 jammy-server-cloudimg-amd64.img local
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local:9000/vm-9000-disk-0.raw
```
Estamos quase prontos. Temos que adicionar um disco que é onde vamos armazenar as configurações personalizadas:

`qm set 9000 --ide2 local:cloudinit`

Configurando a ordem de boot:

`qm set 9000 --boot c --bootdisk scsi0`

Algumas imagens de **`amd64`** `cloud-init` são feitas pensando em compatibilidade com o **`Openstack`**. Por isso, temos que adicionar a `serial0` para que ela inicie. Caso tenha curiosidade, remova a `serial0`. Se não inicializar, adicione novamente e tudo vai funcionar:

`qm set 9000 --serial0 socket --vga serial0`

Habilite o **`qemu agent`** na imagem:

`qm set 9000 --agent enabled=1`

Configure a chave `SSH` que será utilizada para a conexão entre seu Desktop e as máquinas virtuais que serão provisionadas no `Proxmox`:

`qm set 9000 --sshkey /tmp/id_rsa.pub`

Defina o usuário que vai ter permissão de **`sudo`**:

`qm set 9000 --ciuser sysadmin`

Faça o upload dos arquivos para a imagem que está sendo configurada:

```
virt-customize -a jammy-server-cloudimg-amd64.img --upload \ /tmp/sshd_config:/etc/ssh/sshd_config
virt-customize -a jammy-server-cloudimg-amd64.img --upload \
/tmp/.vimrc:/home/sysadmin/.vimrc
virt-customize -a jammy-server-cloudimg-amd64.img --upload \
/tmp/.vimrc:/home/sysadmin/.bashrc
```

Defina o tipo de máquina. Dica valiosa do Tomas da [2w-consultoria](https://www.2w.eti.br/):
`qm set 9000 --machine q35`

Por fim, transforme esta máquina em um template:

`qm template 9000`
> Este é o último passo para utilizar o template no `Terraform` para provisionar máquinas virtuais no `Proxmox`.

### Instalação e configuração do `Terraform`:
Para a instalação do **`Terraform`** podemos acessar a [página de documentação](https://developer.hashicorp.com/terraform/downloads).