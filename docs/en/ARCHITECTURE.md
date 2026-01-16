# Architecture Diagram

[🇫🇷 Version française](../fr/ARCHITECTURE.md) | 🇬🇧 English version

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            Internet / Your PC                                │
│                                                                              │
│  💻 Your PC (95.178.90.149)                                                 │
│     - AWS CLI + Session Manager Plugin                                      │
│     - MySQL Client                                                           │
└────────────────────────────────┬─────────────────────────────────────────────┘
                                 │
                                 │ AWS SSM (HTTPS 443)
                                 │ Secure tunnel
                                 │
┌────────────────────────────────┼─────────────────────────────────────────────┐
│                                │                                              │
│  VPC: 10.0.0.0/16              │                                              │
│                                │                                              │
│  ┌─────────────────────────────▼──────────────────────────────────────────┐  │
│  │                      Internet Gateway (IGW)                            │  │
│  └────────────────────────────────────────────────────────────────────────┘  │
│                                                                               │
│  ┌───────────────────────────────────────────────────────────────────────┐   │
│  │  Availability Zone: eu-west-1a                                        │   │
│  │                                                                       │   │
│  │  ┌─────────────────────────────────────────────────────────────────┐ │   │
│  │  │  Public Subnet: 10.0.1.0/24                                     │ │   │
│  │  │                                                                 │ │   │
│  │  │  (Empty - no bastion needed with SSM)                          │ │   │
│  │  │                                                                 │ │   │
│  │  └─────────────────────────────────────────────────────────────────┘ │   │
│  │                                                                       │   │
│  │  ┌─────────────────────────────────────────────────────────────────┐ │   │
│  │  │  Private DB Subnet: 10.0.10.0/24                               │ │   │
│  │  │                                                                 │ │   │
│  │  │  ┌───────────────────────────────────────────────────────────┐ │ │   │
│  │  │  │  🗄️  RDS MySQL Database (DEPLOYED)                       │ │ │   │
│  │  │  │  Instance: db.t3.micro                                   │ │ │   │
│  │  │  │  Storage: 20GB gp2                                       │ │ │   │
│  │  │  │  Security Group: database-sg                            │ │ │   │
│  │  │  │  - Ingress: MySQL (3306) from app-sg                    │ │ │   │
│  │  │  │  - Ingress: MySQL (3306) from bastion-sg                │ │ │   │
│  │  │  │  - Egress: All traffic                                  │ │ │   │
│  │  │  │  Endpoint: *.eu-west-1.rds.amazonaws.com               │ │ │   │
│  │  │  └───────────────────────────────────────────────────────────┘ │ │   │
│  │  │                                  ▲                              │ │   │
│  │  └──────────────────────────────────┼──────────────────────────────┘ │   │
│  │                                     │ MySQL (3306)                   │   │
│  └─────────────────────────────────────┼────────────────────────────────┘   │
│                                        │                                     │
│  ┌─────────────────────────────────────┼────────────────────────────────┐   │
│  │  Availability Zone: eu-west-1b      │                                │   │
│  │                                     │                                │   │
│  │  ┌──────────────────────────────────┼─────────────────────────────┐  │   │
│  │  │  Private App Subnet: 10.0.11.0/24│                             │  │   │
│  │  │                                  │                             │  │   │
│  │  │  ┌───────────────────────────────┼──────────────────────────┐  │  │   │
│  │  │  │  🖥️  EC2 App Server (DEPLOYED)│                         │  │  │   │
│  │  │  │  Instance: t2.micro           │                         │  │  │   │
│  │  │  │  IAM Role: SSM Managed        │                         │  │  │   │
│  │  │  │  Security Group: app-sg       │                         │  │  │   │
│  │  │  │  - Ingress: SSH from bastion-sg                         │  │  │   │
│  │  │  │  - Egress: All traffic        │                         │  │  │   │
│  │  │  │  Packages: mysql, postgresql15│                         │  │  │   │
│  │  │  └───────────────────────────────┼──────────────────────────┘  │  │   │
│  │  │                                  │                             │  │   │
│  │  │  ┌───────────────────────────────┼──────────────────────────┐  │  │   │
│  │  │  │  🔌 VPC Endpoints (DEPLOYED)  │                         │  │  │   │
│  │  │  │  - com.amazonaws.eu-west-1.ssm                          │  │  │   │
│  │  │  │  - com.amazonaws.eu-west-1.ssmmessages                  │  │  │   │
│  │  │  │  - com.amazonaws.eu-west-1.ec2messages                  │  │  │   │
│  │  │  │  Security Group: vpc-endpoints-sg                       │  │  │   │
│  │  │  │  - Ingress: HTTPS (443) from VPC                        │  │  │   │
│  │  │  └───────────────────────────────┼──────────────────────────┘  │  │   │
│  │  │                                  │                             │  │   │
│  │  └──────────────────────────────────┼─────────────────────────────┘  │   │
│  │                                     │                                │   │
│  └─────────────────────────────────────┼────────────────────────────────┘   │
│                                        │                                     │
│                                        │ SSM Session                         │
│                                        │ (via VPC Endpoints)                 │
│                                        │                                     │
└────────────────────────────────────────┼─────────────────────────────────────┘
                                         │
                                         │ HTTPS 443
                                         │ (AWS SSM Service)
                                         │
                                         ▼
                            ┌────────────────────────┐
                            │   AWS Systems Manager  │
                            │   Session Manager      │
                            └────────────────────────┘


┌─────────────────────────────────────────────────────────────────────────────┐
│                            Connection Flow                                   │
└─────────────────────────────────────────────────────────────────────────────┘

  💻 Your PC (95.178.90.149)
       │
       │ 1. AWS SSM Start Session (HTTPS 443)
       │    aws ssm start-session --document AWS-StartPortForwardingSessionToRemoteHost
       │    Authentication: AWS SSO (AWSReservedSSO_AdministratorAccess)
       │
       ▼
  🔌 VPC Endpoints SSM (Private App Subnet)
       │
       │ 2. Session Manager establishes tunnel
       │
       ▼
  🖥️  EC2 App Server (Private App Subnet)
       │
       │ 3. Port Forwarding: localhost:3306 → RDS:3306
       │    MySQL client on EC2 relays connection
       │
       ▼
  🗄️  RDS MySQL Database (Private DB Subnet)
       │
       │ 4. MySQL connection established
       │    Security Group: app-sg → database-sg authorized
       │
       ▼
  ✅ Database access from your PC


┌─────────────────────────────────────────────────────────────────────────────┐
│                     Architecture Advantages                                  │
└─────────────────────────────────────────────────────────────────────────────┘

✅ No public exposure
   - No public IP on EC2 App
   - No direct Internet access to DB
   - No exposed bastion

✅ Multi-layer security
   - AWS SSO with MFA
   - IAM Role on EC2
   - Restrictive Security Groups
   - Private VPC Endpoints
   - Complete CloudTrail audit

✅ No NAT Gateway needed
   - VPC Endpoints enable SSM without Internet
   - Saves ~$32/month

✅ Easy to use
   - Single command for tunnel
   - No SSH key management
   - No bastion to maintain


┌─────────────────────────────────────────────────────────────────────────────┐
│                         Deployed Resources                                   │
└─────────────────────────────────────────────────────────────────────────────┘

✅ Deployed (Free Tier or low cost):
  - 1 VPC (free)
  - 1 Internet Gateway (free)
  - 3 Subnets: 1 public + 2 private (free)
  - 3 Route Tables (free)
  - 4 Security Groups (free)
  - 1 DB Subnet Group (free)
  - 1 EC2 App Server t2.micro (750h/month free)
  - 1 RDS MySQL db.t3.micro, 20GB (750h/month free)
  - 3 VPC Endpoints for SSM (~$0.01/h = ~$7/month)
  - 1 IAM Role + Policies (free)

❌ Not deployed (savings):
  - NAT Gateway (~$0.045/hour = ~$32/month)
  - Elastic IP for NAT (~$3.60/month if unattached)
  - Bastion Host (not needed with SSM)

💰 Estimated monthly cost: ~$7/month (VPC Endpoints only)
   Without VPC Endpoints + with NAT Gateway: ~$39/month


┌─────────────────────────────────────────────────────────────────────────────┐
│                         Routing Tables                                       │
└─────────────────────────────────────────────────────────────────────────────┘

Public Route Table:
  - 10.0.0.0/16 → local
  - 0.0.0.0/0   → Internet Gateway

Private Route Table:
  - 10.0.0.0/16 → local
  - (no outbound Internet access - NAT Gateway disabled)
```
