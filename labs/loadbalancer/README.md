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


## Exemplo de Load Balancer Interno
```hcl
########################################################################
### LoadBalancer Private
########################################################################
module "loadbalancer_private" {
  source   = "../../modules/loadbalancer"
  rg_name  = module.rg.rg_name
  location = module.rg.location
  tags     = var.tags

  for_each = var.loadbalancer_private

  lb = {
    name     = each.value.name
    sku      = each.value.sku
    sku_tier = each.value.sku_tier

    frontend_ip_configuration = {
      frontendip = {
        name                          = "${each.value.frontend_ip_configuration.frontendip.name}-${each.value.name}"
        private_ip_address_allocation = each.value.frontend_ip_configuration.frontendip.private_ip_address_allocation
        private_ip_address            = each.value.frontend_ip_configuration.frontendip.private_ip_address
        subnet_id                     = module.network.subnet_ids["loadbalancer"]
      }
    }
  }
  lb_probes = each.value.lb_probes

  lb_rules = {
    for rule_key, rule in each.value.lb_rules :
    rule_key => merge(
      rule,
      {
        frontend_ip_configuration_name = "${each.value.frontend_ip_configuration.frontendip.name}-${each.value.name}"
      }
    )
  }

    nic_be_pool_associations = {
    for vm_key, vm in module.vms_web :
    vm_key => {
      network_interface_id  = vm.nic_id
      ip_configuration_name = vm.nic_ip_configuration_name
    }
  }
}

### LoadBalancer Private - Output

output "loadbalancers_private_ips" {
  description = "IPs privados dos Load Balancers internos"
  value = {
    for _, lb in module.loadbalancer_private :
    lb.lb_name => one(values(lb.private_ips))
  }
}

```


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