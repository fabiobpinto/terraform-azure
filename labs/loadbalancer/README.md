# Terraform Azure Loadbalancer Lab



---

## 🧱 Arquitetura do Lab



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

- Criar uma **VNET** utilizando Terraform
- Implementar **Network Security Groups (NSG)** por subnet
- Provisionar **Linux Virtual Machines** sem IP público
- Utilizar **cloud-init (`custom_data`)** para bootstrap das VMs
- Organizar o código usando **modules reutilizáveis** e **labs independentes**

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







---

## 🚀 Como Executar o Lab
```bash
cd labs/bastion
terraform init
terraform plan -var-file="prd.tfvars"
terraform apply -var-file="prd.tfvars"
```

---

## 🔎 Validações

- Verificar criação da VNET e subnets no Azure Portal
- Validar NSGs associados às subnets
- Verificar Azure Bastion Service ativo

---

## 🧹 Remoção dos Recursos
```bash
terraform destroy -var-file="prd.tfvars"
```

---

## 👤 Autor

Fábio Brito Pinto
Cloud Engineer | Terraform | Azure