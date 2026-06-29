# Terraform Azure Loadbalancer Lab

Este laboratório tem como objetivo demonstrar, na prática, a criação e configuração de um **Azure Standard Load Balancer** utilizando **Terraform**, seguindo boas práticas de Infraestrutura como Código (IaC).


---

## 🧱 Arquitetura do Lab

A arquitetura do laboratório é composta por um Load Balancer Standard público, distribuindo tráfego para múltiplas máquinas virtuais Linux em uma Virtual Network, com regras de balanceamento e Inbound NAT configuradas.

- Servidores Linux (Web VM)
- Public IP
- Load Balancer (Backend Pool, Inbound Nat Rules, Health Probe e Load Balancing rules)
- Subnets
- NSG

📐 Diagrama da arquitetura:

![Azure Loadbalancer Architecture](https://github.com/fabiobpinto/terraform-azure/blob/main/docs/loadbalancer-architecture.png)


### Load Balancer Resources

[azurerm_lb](https://registry.terraform.io/providers/hashicorp/Azurerm/3.77.0/docs/resources/lb)

[azurerm_lb_backend_address_pool](https://registry.terraform.io/providers/hashicorp/Azurerm/3.77.0/docs/resources/lb_backend_address_pool)

[azurerm_lb_backend_address_pool_address](https://registry.terraform.io/providers/hashicorp/Azurerm/3.77.0/docs/resources/lb_backend_address_pool_address)

[azurerm_network_interface_backend_address_pool_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_backend_address_pool_association)

[azurerm_lb_probe](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_probe)

[azurerm_lb_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_rule)

[azurerm_lb_outbound_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_outbound_rule)

[azurerm_lb_nat_pool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_nat_pool)

[azurerm_lb_nat_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_rule)


---

## 🎯 Objetivos do Laboratório

- Criar um **Azure Standard Load Balancer** utilizando Terraform
- Provisionar **Public IP** para exposição do Load Balancer
- Implementar **Backend Address Pool** com múltiplas VMs Linux
- Configurar **Health Probes (TCP)** para monitoramento dos backends
- Criar **Load Balancer Rules** para distribuição de tráfego
- Implementar **Inbound NAT Rules** para acesso administrativo às VMs
- Associar NICs das VMs ao Backend Pool
- Organizar o código utilizando **modules reutilizáveis** e **labs independentes**


---

## 🗂️ Estrutura do Repositório

```text
.
├── labs
│   └── loadbalancer
│       ├── main.tf
│       ├── provider.tf
│       ├── variables.tf
│       ├── prd.tfvars
│       └── output.tf
└── modules
    ├── bastion
    ├── loadbalancer
    ├── resource_group
    ├── virtual_network
    ├── nsg
    ├── public_ip
    ├── vm_linux
    └── model

```
---

## 🔐 Segurança e Boas Práticas

- Utilização do **Azure Standard Load Balancer**, que exige configuração explícita de regras
- Separação de responsabilidades utilizando **módulos Terraform**
- Uso de **Health Probes** para garantir tráfego apenas para backends saudáveis
- Associação explícita das NICs ao Backend Pool
- Uso de **Inbound NAT Rules** apenas para fins de administração
- Infraestrutura totalmente declarativa e idempotente

---

## 🚀 Como Executar o Lab
```bash
cd labs/loadbalancer
terraform init
terraform plan -var-file="prd.tfvars"
terraform apply -var-file="prd.tfvars"
```

---

## 🔎 Validações

- Validar a criação do **Azure Standard Load Balancer** no Portal
- Verificar se as VMs estão associadas corretamente ao **Backend Pool**
- Validar o status dos **Health Probes**
- Testar o acesso às aplicações via IP público do Load Balancer
- Verificar o acesso individual às VMs através das **Inbound NAT Rules**

---

## 🧹 Remoção dos Recursos
```bash
terraform destroy -var-file="prd.tfvars"
```

---

## 👤 Autor

Fábio Brito Pinto
Cloud Engineer | Terraform | Azure