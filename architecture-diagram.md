# Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            Internet / Votre PC                               │
│                                                                              │
│  💻 Votre PC (95.178.90.149)                                                │
│     - AWS CLI + Session Manager Plugin                                      │
│     - MySQL Client                                                           │
└────────────────────────────────┬─────────────────────────────────────────────┘
                                 │
                                 │ AWS SSM (HTTPS 443)
                                 │ Tunnel sécurisé
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
│  │  │  (Vide - pas de bastion nécessaire avec SSM)                   │ │   │
│  │  │                                                                 │ │   │
│  │  └─────────────────────────────────────────────────────────────────┘ │   │
│  │                                                                       │   │
│  │  ┌─────────────────────────────────────────────────────────────────┐ │   │
│  │  │  Private DB Subnet: 10.0.10.0/24                               │ │   │
│  │  │                                                                 │ │   │
│  │  │  ┌───────────────────────────────────────────────────────────┐ │ │   │
│  │  │  │  🗄️  RDS MySQL Database (DÉPLOYÉ)                       │ │ │   │
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
│  │  │  │  🖥️  EC2 App Server (DÉPLOYÉ)│                         │  │  │   │
│  │  │  │  Instance: t2.micro           │                         │  │  │   │
│  │  │  │  IAM Role: SSM Managed        │                         │  │  │   │
│  │  │  │  Security Group: app-sg       │                         │  │  │   │
│  │  │  │  - Ingress: SSH from bastion-sg                         │  │  │   │
│  │  │  │  - Egress: All traffic        │                         │  │  │   │
│  │  │  │  Packages: mysql, postgresql15│                         │  │  │   │
│  │  │  └───────────────────────────────┼──────────────────────────┘  │  │   │
│  │  │                                  │                             │  │   │
│  │  │  ┌───────────────────────────────┼──────────────────────────┐  │  │   │
│  │  │  │  🔌 VPC Endpoints (DÉPLOYÉS)  │                         │  │  │   │
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
│                            Flux de connexion                                 │
└─────────────────────────────────────────────────────────────────────────────┘

  💻 Votre PC (95.178.90.149)
       │
       │ 1. AWS SSM Start Session (HTTPS 443)
       │    aws ssm start-session --document AWS-StartPortForwardingSessionToRemoteHost
       │    Authentification: AWS SSO (AWSReservedSSO_AdministratorAccess)
       │
       ▼
  🔌 VPC Endpoints SSM (Private App Subnet)
       │
       │ 2. Session Manager établit le tunnel
       │
       ▼
  🖥️  EC2 App Server (Private App Subnet)
       │
       │ 3. Port Forwarding: localhost:3306 → RDS:3306
       │    MySQL client sur l'EC2 fait le relais
       │
       ▼
  🗄️  RDS MySQL Database (Private DB Subnet)
       │
       │ 4. Connexion MySQL établie
       │    Security Group: app-sg → database-sg autorisé
       │
       ▼
  ✅ Accès à la base de données depuis votre PC
     mysql -h 127.0.0.1 -P 3306 -u admin -p


┌─────────────────────────────────────────────────────────────────────────────┐
│                     Avantages de cette architecture                          │
└─────────────────────────────────────────────────────────────────────────────┘

✅ Aucune exposition publique
   - Pas d'IP publique sur l'EC2 App
   - Pas d'accès Internet direct à la DB
   - Pas de bastion exposé

✅ Sécurité multi-couches
   - AWS SSO avec MFA
   - IAM Role sur l'EC2
   - Security Groups restrictifs
   - VPC Endpoints privés
   - CloudTrail audit complet

✅ Pas de NAT Gateway nécessaire
   - VPC Endpoints permettent SSM sans Internet
   - Économie de ~$32/mois

✅ Simplicité d'utilisation
   - Une seule commande pour le tunnel
   - Pas de gestion de clés SSH
   - Pas de bastion à maintenir


┌─────────────────────────────────────────────────────────────────────────────┐
│                         Ressources déployées                                 │
└─────────────────────────────────────────────────────────────────────────────┘

✅ Déployé (Free Tier ou faible coût):
  - 1 VPC (gratuit)
  - 1 Internet Gateway (gratuit)
  - 3 Subnets: 1 public + 2 privés (gratuit)
  - 3 Route Tables (gratuit)
  - 4 Security Groups (gratuit)
  - 1 DB Subnet Group (gratuit)
  - 1 EC2 App Server t2.micro (750h/mois gratuit)
  - 1 RDS MySQL db.t3.micro, 20GB (750h/mois gratuit)
  - 3 VPC Endpoints pour SSM (~$0.01/h = ~$7/mois)
  - 1 IAM Role + Policies (gratuit)

❌ Non déployé (économie):
  - NAT Gateway (~$0.045/heure = ~$32/mois)
  - Elastic IP pour NAT (~$3.60/mois si non attachée)
  - Bastion Host (pas nécessaire avec SSM)

💰 Coût mensuel estimé: ~$7/mois (VPC Endpoints uniquement)
   Sans VPC Endpoints + avec NAT Gateway: ~$39/mois


┌─────────────────────────────────────────────────────────────────────────────┐
│                         Tables de routage                                    │
└─────────────────────────────────────────────────────────────────────────────┘

Public Route Table:
  - 10.0.0.0/16 → local
  - 0.0.0.0/0   → Internet Gateway

Private Route Table:
  - 10.0.0.0/16 → local
  - (pas d'accès Internet sortant - NAT Gateway désactivé)
```
