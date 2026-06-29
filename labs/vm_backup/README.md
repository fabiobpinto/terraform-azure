# Terraform Azure VM Backup Lab

Este laboratório demonstra o uso do Terraform no Microsoft Azure para provisionar uma solução de **backup de Máquinas Virtuais (VMs)** utilizando o **Azure Recovery Services Vault**.

O objetivo é aplicar conceitos de proteção de workloads, políticas de backup e recuperação de desastres, seguindo boas práticas de Infrastructure as Code (IaC).

---

## 🧱 Arquitetura do Lab

A arquitetura é composta pelos seguintes componentes:

- Resource Group
- Recovery Services Vault
- Backup Policy
- Azure Virtual Machines
- Associação das VMs à política de backup
- Recovery Points gerenciados pelo Azure Backup

### Fluxo do Backup

- O Recovery Services Vault armazena os backups das máquinas virtuais.
- Uma Backup Policy define frequência, horário e retenção dos backups.
- As máquinas virtuais são registradas no Vault.
- O Azure Backup executa automaticamente os backups conforme a política configurada.
- Os Recovery Points ficam disponíveis para restauração quando necessário.

📐 **Diagrama da arquitetura:**

![Azure VM Backup](https://github.com/fabiobpinto/terraform-azure/blob/main/docs/vm_rsv.png)

---

## 🎯 Objetivos do Laboratório

- Provisionar um Azure Recovery Services Vault
- Criar uma Backup Policy personalizada
- Proteger uma ou mais Azure Virtual Machines
- Demonstrar a associação entre VMs e políticas de backup
- Organizar a infraestrutura utilizando módulos reutilizáveis
- Automatizar toda a configuração utilizando Terraform

---

## 🗂️ Estrutura do Repositório

```text
.
├── labs
│   └── vm_backup
│       ├── main.tf
│       ├── provider.tf
│       ├── variables.tf
│       ├── prd.tfvars
│       └── output.tf
└── modules
    ├── resource_group
    ├── backup_vault
    └── virtual_machine
```

---

## ⚙️ Componentes da Solução

### Recovery Services Vault

Responsável por armazenar e gerenciar os backups das máquinas virtuais.

#### Características

- Armazenamento centralizado dos backups
- Gerenciamento dos Recovery Points
- Integração nativa com Azure Backup
- Configuração automatizada via Terraform

---

### Backup Policy

Define como os backups serão executados.

#### Recursos utilizados

- Frequência (Daily ou Weekly)
- Horário de execução
- Configuração de retenção diária
- Associação automática às máquinas protegidas

---

### Protected Virtual Machine

Representa a associação entre uma máquina virtual e uma política de backup.

#### Benefícios

- Proteção automatizada
- Criação periódica de Recovery Points
- Recuperação simplificada
- Gerenciamento centralizado pelo Recovery Services Vault

---

## 🔐 Segurança e Boas Práticas

- Backup centralizado utilizando Recovery Services Vault
- Políticas reutilizáveis para múltiplas VMs
- Infraestrutura totalmente definida como código
- Código organizado em módulos reutilizáveis
- Configurações parametrizadas através de variáveis
- Arquivos sensíveis ignorados via `.gitignore`

---

## 🚀 Como Executar o Lab

```bash
cd labs/vm_backup

terraform init

terraform plan -var-file="prd.tfvars"

terraform apply -var-file="prd.tfvars"
```

---

## 🔎 Validações

Após o provisionamento:

### Recovery Services Vault

- Confirmar a criação do Recovery Services Vault no Azure Portal
- Verificar a região configurada

### Backup Policy

- Confirmar a criação da política de backup
- Validar frequência e horário configurados
- Verificar as configurações de retenção

### Protected Virtual Machines

- Confirmar que as máquinas virtuais estão protegidas
- Validar a associação com a Backup Policy

### Backup

- Executar um backup sob demanda (opcional)
- Confirmar a criação dos Recovery Points
- Validar o status da proteção das VMs

---

## 🧹 Remoção dos Recursos

```bash
terraform destroy -var-file="prd.tfvars"
```

> **Observação:** O comportamento da remoção dos backups depende das configurações definidas no bloco `features.recovery_service` do provider `azurerm`, podendo manter ou excluir os itens protegidos durante o `terraform destroy`.

---

## 👤 Autor

**Fábio Brito Pinto**

Cloud Engineer | Terraform | Azure