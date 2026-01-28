# Terraform Azure Bastion Lab

Este laboratório tem como objetivo demonstrar, de forma prática, o uso do **Terraform** para provisionar uma arquitetura segura no **Microsoft Azure**, utilizando **Azure Virtual Network**, **Network Security Group**, **Linux Virtual Machines** e **Azure Bastion Service**.

O foco do lab é aplicar **boas práticas de Infraestrutura como Código (IaC)**, organização de módulos e acesso seguro às VMs **sem exposição de IP público**.

Caso queira acessar o servidor pelo ip publico basta habilitar o parametro **enable_public_ip** nas variaveis da VM.

---

## 🧱 Arquitetura do Lab

A infraestrutura é composta por uma **VNET segmentada em múltiplas subnets**, seguindo um modelo multi-tier:

- Bastion Subnet (Azure Bastion Service)
- Web Subnet (Web VM)
- App Subnet (App VM)
- DB Subnet (reservada para expansão)

O acesso às VMs é realizado exclusivamente via **Azure Bastion**, utilizando **HTTPS (porta 443)** através do Azure Portal.

📐 Diagrama da arquitetura:

![Azure Bastion Architecture](https://github.com/fabiobpinto/terraform-azure/blob/main/docs/bastion-architecture.png)

---

## 🎯 Objetivos do Laboratório

- Criar uma **VNET** utilizando Terraform
- Implementar **Network Security Groups (NSG)** por subnet
- Provisionar **Linux Virtual Machines** sem IP público
- Utilizar **cloud-init (`custom_data`)** para bootstrap das VMs
- Implementar **Azure Bastion Service** para acesso seguro
- Organizar o código usando **modules reutilizáveis** e **labs independentes**

---

## 🗂️ Estrutura do Repositório

```text
.
├── labs
│   └── bastion
│       ├── main.tf
│       ├── provider.tf
│       ├── variables.tf
│       ├── prd.tfvars
│       └── output.tf
└── modules
    ├── bastion
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
terraform workspace new prd
terraform workspace select prd
terraform plan -var-file="prd.tfvars"
terraform apply -var-file="prd.tfvars"
```

---

## 🔎 Validações

- Verificar criação da VNET e subnets no Azure Portal
- Validar NSGs associados às subnets
- Verificar Azure Bastion Service ativo
- Conectar nas VMs via Bastion (SSH) pelo portal

---

## 🧹 Remoção dos Recursos
```bash
terraform destroy -var-file="prd.tfvars"
```

---

## 👤 Autor

Fábio Brito Pinto
Cloud Engineer | Terraform | Azure