# Terraform Azure VMSS + ASG Lab

Este laboratório demonstra o uso do Terraform no Microsoft Azure para provisionar uma arquitetura escalável baseada em Virtual Machine Scale Sets (VMSS), integrada com Application Security Groups (ASG), Network Security Groups (NSG) e Azure Load Balancer.

O objetivo é aplicar conceitos de escala horizontal, segmentação de rede e segurança baseada em identidade de aplicação, seguindo boas práticas de Infrastructure as Code (IaC).

---

## 🧱 Arquitetura do Lab

A arquitetura é composta pelos seguintes componentes:

- Resource Group centralizado
- Virtual Network com subnets segmentadas
- Application Security Groups (ASG)
- Network Security Groups (NSG) associados às subnets
- Virtual Machine Scale Set (VMSS Linux)
- Azure Load Balancer Público
- Backend Pool integrado ao VMSS
- NAT Rules para acesso administrativo
- Public IP para o Load Balancer
- Fluxo de acesso
- Usuários acessam aplicações através do Public IP do Load Balancer
- O Load Balancer distribui o tráfego para as instâncias do VMSS
- O VMSS é associado ao Backend Pool
- Os NSGs controlam o tráfego de entrada e saída
- Os ASGs permitem aplicar regras de segurança baseadas na função das máquinas

📐 Diagrama da arquitetura:

![Azure VMSS e ASG](https://github.com/fabiobpinto/terraform-azure/blob/main/docs/vmss_asg.png)

---

## 🎯 Objetivos do Laboratório
- Provisionar um Azure Virtual Machine Scale Set
- Implementar Application Security Groups (ASG)
- Implementar Network Security Groups (NSG)
- Configurar um Azure Load Balancer Público
- Associar o VMSS ao Backend Pool do Load Balancer
- Implementar regras de NAT para acesso administrativo
- Demonstrar segmentação de rede utilizando ASG + NSG
- Organizar a infraestrutura utilizando módulos reutilizáveis

---

## 🗂️ Estrutura do Repositório
```text
.
├── labs
│   └── vmss
│       ├── main.tf
│       ├── provider.tf
│       ├── variables.tf
│       ├── prd.tfvars
│       └── output.tf
└── modules
    ├── resource_group
    ├── virtual_network
    ├── nsg
    ├── asg
    ├── public_ip
    ├── loadbalancer
    └──  vmss_linux

```
---

## ⚙️ Componentes da Solução
### Virtual Machine Scale Set (VMSS)

Responsável pela criação e gerenciamento das instâncias Linux de forma escalável.

#### Características:

Escala horizontal simplificada
Integração com Azure Load Balancer
Associação com Application Security Groups
Provisionamento automatizado via Terraform
Application Security Groups (ASG)

Permitem agrupar recursos por função lógica.

#### Exemplo:

web → servidores web

Os ASGs são utilizados pelos NSGs para criar regras mais simples e reutilizáveis.

Network Security Groups (NSG)

Aplicados às subnets para controlar o tráfego de rede.

#### Benefícios:

Controle granular de acesso
Regras baseadas em ASG
Segmentação lógica entre camadas da aplicação
Azure Load Balancer

Responsável por distribuir o tráfego para as instâncias do VMSS.

#### Recursos utilizados:

Frontend IP Público
Backend Address Pool
Load Balancing Rules
Inbound NAT Rules
Health Probes

---

## 🔐 Segurança e Boas Práticas
Segmentação de rede utilizando subnets dedicadas
Controle de acesso via NSG
Regras de segurança baseadas em ASG
Backend Pool isolado do acesso direto dos usuários
Infraestrutura totalmente definida como código
Arquivos sensíveis ignorados via .gitignore
Código organizado em módulos reutilizáveis

---

## 🚀 Como Executar o Lab
```bash
cd labs/vmss

terraform init

terraform plan -var-file="prd.tfvars"

terraform apply -var-file="prd.tfvars"

```

---

## 🔎 Validações

Após o provisionamento:

- Virtual Machine Scale Set
- Verificar a criação do VMSS no Azure Portal
- Confirmar a quantidade de instâncias provisionadas
- Load Balancer
- Validar o Frontend IP Público
- Confirmar o Backend Pool associado ao VMSS
- Verificar Health Probes
- Network Security Group
- Validar associação dos NSGs às subnets
- Confirmar regras de entrada e saída
- Application Security Group
- Confirmar associação das instâncias do VMSS ao ASG configurado
- Conectividade
- Testar acesso através do IP Público do Load Balancer
- Validar regras NAT configuradas

---

## 🧹 Remoção dos Recursos
terraform destroy -var-file="prd.tfvars"

---

## 👤 Autor

Fábio Brito Pinto

Cloud Engineer | Terraform | Azure