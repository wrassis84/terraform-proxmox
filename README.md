# terraform-proxmox
Este repositório contém arquivos e instruções para provisionar máquinas virtuais
no virtualizador [**`Proxmox`**](https://www.proxmox.com/en/) utilizando a ferramenta de `IaC` [**`Terraform`**](https://www.terraform.io/).

Trata-se de um projeto de *homelab* que desenvolvi para praticar o uso de ferramentas *DevOps* como o [**`Terraform`**](https://www.terraform.io/), [**`Proxmox`**](https://www.proxmox.com/en/) e [**`Ansible`**](https://www.ansible.com/).

Primeiramente, será necessário instalar o `Proxmox` no seu hardware. Eu utilizei um *laptop* com 8 GB de RAM, processador CORE I7 (5ª geração) e disco SSD Sata com 500GB de espaço. O `Proxmox` não é muito exigente em termos de hardware, mas tenha em mente que a capacidade do hardware utilizado vai influenciar no desempenho do próprio virtualizador e na quantidade de máquinas virtuais que ele poderá executar.

Em razão de haver muito material disponível na Web sobre a instalação do `Proxmox` e isso ser um processo relativamente simples, não abordarei sua instalação.

Será necessário criar um template de máquina virtual nos moldes do [**`cloud-init`**](https://cloud-init.io/). Para a criação do template que utilizaremos, pode-se visitar a página [Cloud-init no Proxmox Virtual Environment 6](https://golesuite.com/br/blog/blog-post-2/). Embora no site tenha-se criado o template utilizando a versão 6 do **`Proxmox`**, eu utilizei na versão 7 sem problemas.
