# AWS Terraform Infrastructure 🚀

## Project Overview
Automated AWS infrastructure deployment using 
Terraform IaC with CI/CD pipeline via GitHub Actions.
Every push to main branch automatically deploys
infrastructure — zero manual intervention!

---

## Architecture Diagram
INTERNET
                       ↓
              [Internet Gateway]
                       ↓
              [Application Load Balancer]
                (single entry point)
                  ↓         ↓
          ┌──────────┐ ┌──────────┐
          │  Public  │ │  Public  │
          │ Subnet 1 │ │ Subnet 2 │
          │  EC2 +   │ │          │
          │  Nginx   │ │          │
          └──────────┘ └──────────┘
                  ↓         ↓
              [NAT Gateway]
                  ↓
          ┌──────────┐ ┌──────────┐
          │  Private │ │  Private │
          │ Subnet 1 │ │ Subnet 2 │
          │   RDS    │ │          │
          │  MySQL   │ │          │
          └──────────┘ └──────────┘
                       ↓
              [CloudWatch Monitoring]
              [SNS Email Alerts]

---

## Tech Stack

| Tool | Purpose |
|------|---------|
| Terraform | Infrastructure as Code |
| AWS VPC | Networking |
| AWS EC2 | Web Servers |
| AWS RDS | MySQL Database |
| AWS ALB | Load Balancer |
| AWS Secrets Manager | Secret Management |
| AWS CloudWatch | Monitoring & Alerts |
| AWS SNS | Email Notifications |
| GitHub Actions | CI/CD Pipeline |

---

## Terraform Concepts Used

### 1. Modules
Reusable infrastructure components:
- `modules/vpc` → Networking layer
- `modules/ec2` → Web server layer
- `modules/rds` → Database layer
- `modules/alb` → Load balancer layer
- `modules/cloudwatch` → Monitoring layer

### 2. Workspaces
Isolated environments from same code:
- `dev` → 1 EC2 instance (t3.micro)
- `prod` → 2 EC2 instances (t3.micro)

### 3. Remote State + Locking
- State stored in S3 bucket (encrypted)
- DynamoDB prevents simultaneous applies
- Team-safe infrastructure management

### 4. Secrets Management
- Database credentials in AWS Secrets Manager
- Never hardcoded in code
- Fetched at runtime by Terraform

### 5. Provisioners → user_data
- EC2 bootstraps itself on first boot
- Nginx installed automatically
- No SSH needed from pipeline

---

## Project Structure
aws-terraform-infrastructure/
├── .github/
│ └── workflows/
│ └── terraform.yml ← CI/CD pipeline
├── backend-setup/
│ └── main.tf ← S3 + DynamoDB setup
├── configs/
│ └── app.conf ← Nginx config
├── modules/
│ ├── vpc/ ← Networking
│ │ ├── main.tf
│ │ ├── variables.tf
│ │ └── outputs.tf
│ ├── ec2/ ← Web servers
│ │ ├── main.tf
│ │ ├── variables.tf
│ │ └── outputs.tf
│ ├── rds/ ← Database
│ │ ├── main.tf
│ │ ├── variables.tf
│ │ └── outputs.tf
│ ├── alb/ ← Load balancer
│ │ ├── main.tf
│ │ ├── variables.tf
│ │ └── outputs.tf
│ └── cloudwatch/ ← Monitoring
│ ├── main.tf
│ ├── variables.tf
│ └── outputs.tf
├── main.tf ← Root module
├── variables.tf ← Root variables
├── outputs.tf ← Root outputs
├── .gitignore ← Protects secrets
└── README.md ← This file!


---

## Prerequisites

- AWS Account with IAM credentials
- Terraform v1.10+
- Git
- AWS CLI configured

---

## Quick Start

### Step 1 — Clone Repository
```bash
git clone https://github.com/Sakib704596/aws-terraform-infrastructure.git
cd aws-terraform-infrastructure
```

### Step 2 — Setup Backend
```bash
cd backend-setup
terraform init
terraform apply
# Note down bucket name!
cd ..
```

### Step 3 — Generate SSH Key
```bash
ssh-keygen -t rsa -b 2048 -m PEM -f aws-terraform-key
```

### Step 4 — Initialize and Deploy
```bash
terraform init
terraform apply
```

### Step 5 — Verify
```bash
terraform output alb_url
curl http://YOUR-ALB-URL
# Hello from AWS Terraform Infrastructure!
```

---

## CI/CD Pipeline

Every push to main branch:
git push origin main
↓
GitHub Actions triggers
↓
✅ Terraform Init
✅ Terraform Validate
✅ Terraform Plan
✅ Terraform Apply
↓
Infrastructure deployed! 🎉


### GitHub Secrets Required
| Secret | Description |
|--------|-------------|
| AWS_ACCESS_KEY_ID | AWS access key |
| AWS_SECRET_ACCESS_KEY | AWS secret key |
| TF_STATE_BUCKET | S3 bucket name |
| SSH_PUBLIC_KEY | EC2 SSH public key |
| ALERT_EMAIL | CloudWatch alert email |

---

## Monitoring & Alerts

CloudWatch monitors:
| Metric | Threshold | Action |
|--------|-----------|--------|
| EC2 CPU | > 80% | Email alert |
| EC2 Status | Failed | Email alert |
| RDS CPU | > 80% | Email alert |
| RDS Storage | < 5GB | Email alert |
| ALB Unhealthy | > 0 | Email alert |

---

## Environments

| Setting | Dev | Prod |
|---------|-----|------|
| EC2 Count | 1 | 2 |
| Instance Type | t3.micro | t3.micro |
| DB Class | db.t3.micro | db.t3.micro |

Switch environments:
```bash
terraform workspace select dev
terraform workspace select prod
```

---

## Key Learnings

### What I Built
- Multi-tier AWS architecture
- Automated CI/CD pipeline
- Secure secret management
- Real-time monitoring

### Problems I Solved
- SSH key format issues (PEM format)
- State lock conflicts
- Pipeline backend configuration
- user_data vs provisioners

### Security Best Practices
- Private keys never in GitHub
- Secrets in AWS Secrets Manager
- State file encrypted (AES-256)
- Database in private subnet
- Public access blocked on S3

---

## Cost Estimate

| Resource | Cost/hour |
|----------|-----------|
| NAT Gateway | $0.045 |
| EC2 (t3.micro) | $0.010 |
| RDS (db.t3.micro) | $0.017 |
| ALB | $0.008 |
| **Total** | **~$0.08/hr** |

> Always run `terraform destroy` after practice!

---

## Destroy Infrastructure

```bash
# Destroy main infrastructure
terraform destroy

# Destroy backend (S3 + DynamoDB)
cd backend-setup
terraform destroy
```

---

## Author
**Sakib Khan**
GitHub: [@Sakib704596](https://github.com/Sakib704596)