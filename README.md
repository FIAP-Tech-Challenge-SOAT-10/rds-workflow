# Tech Challenge 3 – Provisionamento de Banco de Dados AWS RDS com Terraform e GitHub Actions

Este repositório automatiza a criação de uma instância **AWS RDS MySQL**, com **execução de script SQL** para criação de tabelas e popular dados, utilizando:

- **Terraform**
- **GitHub Actions com OIDC (OpenID Connect)**
- **Secrets seguros**
- **Pipeline de CI/CD**
- **Provisionamento seguro (sem exposição de credenciais)**

---

## 🧩 Visão Geral da Infraestrutura

- 🔒 Banco de dados MySQL provisionado via `aws_db_instance`
- 🔐 Autenticação com AWS via GitHub OIDC Role (sem chave fixa)
- 🎯 População automática com script SQL (`scripts/schema.sql`)
- 🧠 Security Group com dois IPs liberados:
  - Seu IP local (para acesso via SGBD)
  - IP dinâmico do GitHub Runner (somente durante execução)

---

## 📂 Estrutura de Pastas

```bash
.
├── main.tf # Infraestrutura da instância RDS
├── variables.tf # Variáveis utilizadas no projeto
├── outputs.tf # Exibe o endpoint do RDS após apply
├── provider.tf # Provider AWS com uso de role via OIDC
├── scripts/
│   └── schema.sql # Script SQL para criar e popular o banco
└── .github/
    └── workflows/
        ├── deploy.yml # Workflow de criação do RDS + SQL
        └── destroy.yml # Workflow de destruição da infraestrutura
```

---

## 🛡️ Branch Protegida: `main`

A branch `main` está protegida por padrão.  
Para subir mudanças, crie uma nova branch (`feature/...`) e abra um **Pull Request**.

➡️ O merge na `main` só será possível **após aprovação manual** + execução dos workflows no GitHub Actions.

---

## 🔐 Secrets exigidos

Configure os seguintes **secrets** no repositório:

| Nome do Secret           | Descrição                                       |
|--------------------------|-------------------------------------------------|
| `AWS_ROLE_TO_ASSUME`     | ARN da IAM Role com suporte a OIDC             |
| `AWS_REGION`             | Região do RDS (ex: `us-east-1`)                |
| `DB_NAME`                | Nome do banco (ex: `lanchonete`)               |
| `DB_USER`                | Usuário de acesso ao RDS                       |
| `DB_PASSWORD`            | Senha do usuário do RDS                        |
| `MY_IP`                  | Seu IP público com `/32` para liberação no SG  |

---

## 🚀 Deploy via GitHub Actions

1. Faça um **push ou pull request** para a branch `main`
2. O workflow `Terraform Deploy RDS` será executado automaticamente
3. O banco será provisionado e o script SQL executado
4. Ao final, o **endpoint** do banco estará disponível no output

---

## 🧨 Destruir infraestrutura

Para destruir o RDS provisionado:

1. Vá na aba **Actions**
2. Selecione `Terraform Destroy RDS`
3. Clique em **Run workflow**

---

## 🧪 Acessar o banco de dados

Você pode utilizar qualquer cliente MySQL, como:

```bash
mysql -h <endpoint> -u <DB_USER> -p<DB_PASSWORD> <DB_NAME>
```

## ⚠️ Avisos importantes

* Os IPs são limitados para garantir segurança
* O script SQL é executado automaticamente após apply


---

## Diagrama: Provisionamento RDS com terraform + GitHub Actions

```bash
📦 GitHub Repository
 └── .github/workflows/workflow.yml (Terraform CI/CD)

       ⬇
🔐 GitHub Secrets
 ├─ AWS_ROLE_TO_ASSUME (para OIDC)
 ├─ DB_USER / DB_PASSWORD / DB_NAME
 └─ MY_IP (seu IP para acesso via SGBD)

       ⬇
☁️ GitHub Actions (Runner Ubuntu)
 ├─ 1. Assume Role via OIDC
 ├─ 2. Roda `terraform init/plan/apply`
 ├─ 3. Captura IP do Runner (para whitelist temporário)
 ├─ 4. Provisiona RDS privado (MySQL)
 └─ 5. Executa `schema.sql` via mysql-client

       ⬇
🛠️ AWS Infra
 ├─ RDS MySQL (privado)
 └─ Security Group (libera seu IP + do runner)
```