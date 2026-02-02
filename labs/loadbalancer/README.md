# Terraform Azure Loadbalancer Lab



---

## 🧱 Arquitetura do Lab



📐 Diagrama da arquitetura:

![Azure Loadbalancer Architecture](https://github.com/fabiobpinto/terraform-azure/blob/main/docs/loadbalancer-architecture.png)

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

- Nenhuma VM possui IP público (mas pode ser habilitado com (**enable_public_ip = true**)
- Acesso realizado exclusivamente via Azure Bastion
- Bootstrap das VMs realizado via cloud-init
- Separação clara entre labs e modules
- Arquivos sensíveis ignorados via .gitignore


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