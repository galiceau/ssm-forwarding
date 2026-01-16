# AWS SSM RDS Access - Secure Database Access via Systems Manager

[🇫🇷 Version française](../fr/README.md) | 🇬🇧 English version

---

*This is the English version of the documentation. For the French version, see [docs/fr/README.md](../fr/README.md)*

## Overview

This Terraform project deploys an AWS infrastructure to securely access a private RDS MySQL database from the Internet using AWS Systems Manager Session Manager, without exposing any resources publicly.

### Architecture Diagrams

**Simple diagram:**

![SSM RDS Architecture](../../generated-diagrams/aws-architecture-ssm.png)

**Detailed diagram:**

![Detailed Architecture](../../generated-diagrams/aws-architecture-detailed.png)

**Complete ASCII diagram:** See [ARCHITECTURE.md](ARCHITECTURE.md)

**Editable Draw.io diagram:** See [architecture-complete.drawio](../../architecture-complete.drawio)

### Components

- **VPC**: 10.0.0.0/16
- **1 Public Subnet**: 10.0.1.0/24 (for bastion/jump host - empty)
- **1 Private DB Subnet**: 10.0.10.0/24 (for database)
- **1 Private App Subnet**: 10.0.11.0/24 (for backend applications)
- **Internet Gateway**: For Internet access to public subnet
- **EC2 App Server**: t2.micro instance in App subnet (free tier)
- **RDS MySQL**: db.t3.micro instance in DB subnet (free tier)
- **Security Groups**:
  - Bastion: SSH (port 22) from Internet
  - App: SSH from bastion
  - Database: MySQL (3306) from bastion and app server

### Free Tier

**Deployed resources (Free Tier):**
- VPC, Subnets, Route Tables, Internet Gateway: Free
- Security Groups: Free
- EC2 App Server (t2.micro): 750 hours/month free
- RDS MySQL (db.t3.micro, 20GB): 750 hours/month free
- VPC Endpoints (SSM): ~$0.01/hour (~$7/month)

**Not deployed (cost savings):**
- NAT Gateway: ~$0.045/hour + data transfer (~$32/month saved)
- Bastion Host: Optional

## Usage

### Prerequisites

1. **Generate an SSH key pair**:

**Linux:**
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/db-access-test
cat ~/.ssh/db-access-test.pub
```

**Mac:**
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/db-access-test
cat ~/.ssh/db-access-test.pub
```

**Windows PowerShell:**
```powershell
ssh-keygen -t rsa -b 4096 -f $env:USERPROFILE\.ssh\db-access-test
Get-Content $env:USERPROFILE\.ssh\db-access-test.pub
```

2. **Configure variables**:
```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your public key and DB password
```

### Deployment

```bash
terraform init
terraform plan
terraform apply
```

### Database Access from Your PC

**📖 See complete guide: [ACCESS_GUIDE.md](ACCESS_GUIDE.md)**

The guide includes instructions for **Linux, Mac, and Windows**.

**Quick summary (Linux):**

```bash
# 1. Create SSM tunnel
APP_INSTANCE_ID=$(terraform output -raw app_instance_id)
RDS_ENDPOINT=$(terraform output -raw rds_address)

aws ssm start-session \
  --target $APP_INSTANCE_ID \
  --document-name AWS-StartPortForwardingSessionToRemoteHost \
  --parameters "{\"host\":[\"$RDS_ENDPOINT\"],\"portNumber\":[\"3306\"],\"localPortNumber\":[\"3306\"]}" \
  --profile galiceau-labs

# 2. In another terminal, connect
mysql -h 127.0.0.1 -P 3306 -u admin -p
```

**Quick summary (Mac):**

```bash
# 1. Create SSM tunnel
APP_INSTANCE_ID=$(terraform output -raw app_instance_id)
RDS_ENDPOINT=$(terraform output -raw rds_address)

aws ssm start-session \
  --target $APP_INSTANCE_ID \
  --document-name AWS-StartPortForwardingSessionToRemoteHost \
  --parameters "{\"host\":[\"$RDS_ENDPOINT\"],\"portNumber\":[\"3306\"],\"localPortNumber\":[\"3306\"]}" \
  --profile galiceau-labs

# 2. In another terminal, connect
mysql -h 127.0.0.1 -P 3306 -u admin -p
```

**Quick summary (Windows PowerShell):**

```powershell
# 1. Create SSM tunnel
$APP_INSTANCE_ID = terraform output -raw app_instance_id
$RDS_ENDPOINT = terraform output -raw rds_address

aws ssm start-session `
  --target $APP_INSTANCE_ID `
  --document-name AWS-StartPortForwardingSessionToRemoteHost `
  --parameters "{`"host`":[`"$RDS_ENDPOINT`"],`"portNumber`":[`"3306`"],`"localPortNumber`":[`"3306`"]}" `
  --profile galiceau-labs

# 2. In another window
mysql -h 127.0.0.1 -P 3306 -u admin -p
```

✅ No public exposure  
✅ No bastion required  
✅ Free and secure  
✅ Works on Linux, Mac, and Windows

### Cleanup

```bash
terraform destroy
```

## Deployed Architecture

The infrastructure deploys:
- An EC2 instance (t2.micro) in the private App subnet with SSM IAM role
- An RDS MySQL database (db.t3.micro) in the private DB subnet
- VPC Endpoints for AWS Systems Manager (SSM, SSMMessages, EC2Messages)
- Configured security groups to allow communication

### Secure Database Access

**Deployed solution: AWS Systems Manager Session Manager + Port Forwarding**

This solution allows you to access your DB from your PC **without exposing anything publicly**:
- ✅ No bastion required
- ✅ No public IP on EC2
- ✅ No DB exposure
- ✅ Secure tunnel via AWS SSM
- ✅ Complete audit in CloudTrail

See [ACCESS_GUIDE.md](ACCESS_GUIDE.md) for detailed instructions.

## Notes

- NAT Gateway is commented out by default as it's not free (~$0.045/hour)
- Secure access is done via AWS Systems Manager Session Manager (no NAT Gateway needed)
- Private subnets have no outbound Internet access (enhanced security)
- VPC Endpoints allow EC2 to communicate with AWS SSM without Internet

## Security

The infrastructure implements multiple security layers:
1. **IAM/SSO**: Only your AWS profile can use SSM
2. **Private VPC**: EC2 and DB without direct Internet access
3. **Security Groups**: Strict network traffic control
4. **VPC Endpoints**: Secure communication with AWS SSM
5. **CloudTrail**: Complete audit of all connections

---

## 📚 Documentation

- [🇫🇷 Documentation française](../fr/README.md)
- [🇬🇧 English documentation](README.md)
- [Access Guide (EN)](ACCESS_GUIDE.md)
- [Guide d'accès (FR)](../fr/ACCESS_GUIDE.md)
- [Architecture Diagram (EN)](ARCHITECTURE.md)
- [Diagramme d'architecture (FR)](../fr/ARCHITECTURE.md)

---

**License**: MIT  
**Author**: Galiceau Labs  
**Repository**: https://github.com/galiceau/ssm-forwarding
