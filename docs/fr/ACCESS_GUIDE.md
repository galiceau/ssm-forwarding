# Guide d'accès à la base de données privée

## Solution : AWS Systems Manager Session Manager + Port Forwarding

Cette solution permet d'accéder à votre base de données privée depuis votre PC **sans exposer quoi que ce soit publiquement**.

---

## 🐧 Installation sur Linux

### 1. Installer AWS CLI

```bash
# Télécharger et installer
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Vérifier
aws --version
```

### 2. Installer le plugin Session Manager

```bash
# Ubuntu/Debian
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
sudo dpkg -i session-manager-plugin.deb

# Vérifier
session-manager-plugin
```

### 3. Installer le client MySQL

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install mysql-client -y

# Vérifier
mysql --version
```

---

## 🍎 Installation sur Mac

### 1. Installer AWS CLI

**Option A : Installeur PKG (Recommandé)**

```bash
# Télécharger et installer
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /

# Vérifier
aws --version
```

**Option B : Via Homebrew**

```bash
brew install awscli
aws --version
```

### 2. Installer le plugin Session Manager

```bash
# Télécharger
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac/sessionmanager-bundle.zip" -o "sessionmanager-bundle.zip"

# Extraire
unzip sessionmanager-bundle.zip

# Installer
sudo ./sessionmanager-bundle/install -i /usr/local/sessionmanagerplugin -b /usr/local/bin/session-manager-plugin

# Vérifier
session-manager-plugin
```

### 3. Installer le client MySQL

**Option A : Via Homebrew (Recommandé)**

```bash
# Installer MySQL client
brew install mysql-client

# Ajouter au PATH (ajouter à ~/.zshrc ou ~/.bash_profile)
echo 'export PATH="/usr/local/opt/mysql-client/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Vérifier
mysql --version
```

**Option B : MySQL complet**

```bash
brew install mysql
mysql --version
```

**Option C : Client GUI (plus simple)**

```bash
# DBeaver (recommandé)
brew install --cask dbeaver-community

# MySQL Workbench
brew install --cask mysqlworkbench
```

---

## 🪟 Installation sur Windows

### 1. Installer AWS CLI

**Option A : Installeur MSI (Recommandé)**

1. Téléchargez : https://awscli.amazonaws.com/AWSCLIV2.msi
2. Double-cliquez et suivez l'assistant d'installation
3. Ouvrez PowerShell et vérifiez :

```powershell
aws --version
```

**Option B : Via winget**

```powershell
winget install Amazon.AWSCLI
```

### 2. Installer le plugin Session Manager

1. Téléchargez : https://s3.amazonaws.com/session-manager-downloads/plugin/latest/windows/SessionManagerPluginSetup.exe
2. Double-cliquez et installez
3. Redémarrez PowerShell
4. Vérifiez :

```powershell
session-manager-plugin
```

### 3. Installer le client MySQL

**Option A : MySQL Installer (Recommandé)**

1. Téléchargez : https://dev.mysql.com/downloads/installer/
2. Choisissez "mysql-installer-community"
3. Installez uniquement "MySQL Command Line Client"
4. Ajoutez MySQL au PATH (l'installeur le fait automatiquement)

**Option B : Via Chocolatey**

```powershell
choco install mysql-cli
```

**Option C : Client GUI (plus simple)**

Installez DBeaver ou MySQL Workbench :
- DBeaver : https://dbeaver.io/download/
- MySQL Workbench : https://dev.mysql.com/downloads/workbench/

---

## 🚀 Utilisation

### Méthode 1 : Port Forwarding direct vers RDS (Recommandé)

**Linux :**

```bash
# 1. Récupérer les informations
APP_INSTANCE_ID=$(terraform output -raw app_instance_id)
RDS_ENDPOINT=$(terraform output -raw rds_address)

# 2. Créer le tunnel (laisser ce terminal ouvert)
aws ssm start-session \
  --target $APP_INSTANCE_ID \
  --document-name AWS-StartPortForwardingSessionToRemoteHost \
  --parameters "{\"host\":[\"$RDS_ENDPOINT\"],\"portNumber\":[\"3306\"],\"localPortNumber\":[\"3306\"]}" \
  --profile galiceau-labs

# 3. Dans un autre terminal, connectez-vous
mysql -h 127.0.0.1 -P 3306 -u admin -p
```

**Mac :**

```bash
# 1. Récupérer les informations
APP_INSTANCE_ID=$(terraform output -raw app_instance_id)
RDS_ENDPOINT=$(terraform output -raw rds_address)

# 2. Créer le tunnel (laisser ce terminal ouvert)
aws ssm start-session \
  --target $APP_INSTANCE_ID \
  --document-name AWS-StartPortForwardingSessionToRemoteHost \
  --parameters "{\"host\":[\"$RDS_ENDPOINT\"],\"portNumber\":[\"3306\"],\"localPortNumber\":[\"3306\"]}" \
  --profile galiceau-labs

# 3. Dans un autre terminal, connectez-vous
mysql -h 127.0.0.1 -P 3306 -u admin -p
```

**Windows PowerShell :**

```powershell
# 1. Récupérer les informations
$APP_INSTANCE_ID = terraform output -raw app_instance_id
$RDS_ENDPOINT = terraform output -raw rds_address

# 2. Créer le tunnel (laisser cette fenêtre ouverte)
aws ssm start-session `
  --target $APP_INSTANCE_ID `
  --document-name AWS-StartPortForwardingSessionToRemoteHost `
  --parameters "{`"host`":[`"$RDS_ENDPOINT`"],`"portNumber`":[`"3306`"],`"localPortNumber`":[`"3306`"]}" `
  --profile galiceau-labs

# 3. Dans une autre fenêtre PowerShell, connectez-vous
mysql -h 127.0.0.1 -P 3306 -u admin -p
```

**Windows CMD :**

```cmd
REM 1. Récupérer les informations
FOR /F "tokens=*" %%i IN ('terraform output -raw app_instance_id') DO SET APP_INSTANCE_ID=%%i
FOR /F "tokens=*" %%i IN ('terraform output -raw rds_address') DO SET RDS_ENDPOINT=%%i

REM 2. Créer le tunnel
aws ssm start-session ^
  --target %APP_INSTANCE_ID% ^
  --document-name AWS-StartPortForwardingSessionToRemoteHost ^
  --parameters "{\"host\":[\"%RDS_ENDPOINT%\"],\"portNumber\":[\"3306\"],\"localPortNumber\":[\"3306\"]}" ^
  --profile galiceau-labs

REM 3. Dans une autre fenêtre CMD
mysql -h 127.0.0.1 -P 3306 -u admin -p
```

### Méthode 2 : Client GUI (DBeaver, MySQL Workbench)

1. **Créer le tunnel SSM** (comme ci-dessus, laisser ouvert)

2. **Configurer le client GUI** :
   - **Host :** 127.0.0.1
   - **Port :** 3306
   - **User :** admin
   - **Password :** (celui dans terraform.tfvars)
   - **Database :** testdb

3. **Se connecter** - Le client se connecte via le tunnel !

### Méthode 3 : Session interactive sur l'EC2

Si vous préférez vous connecter à l'EC2 et utiliser MySQL depuis là :

**Linux :**

```bash
# Se connecter à l'instance
aws ssm start-session \
  --target $(terraform output -raw app_instance_id) \
  --profile galiceau-labs

# Une fois connecté, utiliser MySQL
mysql -h $(terraform output -raw rds_endpoint) -u admin -p
```

**Mac :**

```bash
# Se connecter à l'instance
aws ssm start-session \
  --target $(terraform output -raw app_instance_id) \
  --profile galiceau-labs

# Une fois connecté, utiliser MySQL
mysql -h $(terraform output -raw rds_endpoint) -u admin -p
```

**Windows PowerShell :**

```powershell
# Se connecter à l'instance
aws ssm start-session `
  --target $(terraform output -raw app_instance_id) `
  --profile galiceau-labs

# Une fois connecté, utiliser MySQL
mysql -h <rds-endpoint> -u admin -p
```

---

## 📝 Script automatisé

### Linux

Créez `connect-db.sh` :

```bash
#!/bin/bash
echo "🔌 Création du tunnel SSM vers la base de données..."

APP_INSTANCE_ID=$(terraform output -raw app_instance_id)
RDS_ENDPOINT=$(terraform output -raw rds_address)

echo "📡 Instance: $APP_INSTANCE_ID"
echo "🗄️  Database: $RDS_ENDPOINT"
echo ""
echo "✅ Tunnel créé ! Connectez-vous avec :"
echo "   mysql -h 127.0.0.1 -P 3306 -u admin -p"
echo ""

aws ssm start-session \
  --target $APP_INSTANCE_ID \
  --document-name AWS-StartPortForwardingSessionToRemoteHost \
  --parameters "{\"host\":[\"$RDS_ENDPOINT\"],\"portNumber\":[\"3306\"],\"localPortNumber\":[\"3306\"]}" \
  --profile galiceau-labs
```

```bash
chmod +x connect-db.sh
./connect-db.sh
```

### Mac

Créez `connect-db.sh` :

```bash
#!/bin/bash
echo "🔌 Création du tunnel SSM vers la base de données..."

APP_INSTANCE_ID=$(terraform output -raw app_instance_id)
RDS_ENDPOINT=$(terraform output -raw rds_address)

echo "📡 Instance: $APP_INSTANCE_ID"
echo "🗄️  Database: $RDS_ENDPOINT"
echo ""
echo "✅ Tunnel créé ! Connectez-vous avec :"
echo "   mysql -h 127.0.0.1 -P 3306 -u admin -p"
echo ""

aws ssm start-session \
  --target $APP_INSTANCE_ID \
  --document-name AWS-StartPortForwardingSessionToRemoteHost \
  --parameters "{\"host\":[\"$RDS_ENDPOINT\"],\"portNumber\":[\"3306\"],\"localPortNumber\":[\"3306\"]}" \
  --profile galiceau-labs
```

```bash
chmod +x connect-db.sh
./connect-db.sh
```

### Windows PowerShell

Créez `connect-db.ps1` :

```powershell
Write-Host "🔌 Création du tunnel SSM vers la base de données..." -ForegroundColor Green

$APP_INSTANCE_ID = terraform output -raw app_instance_id
$RDS_ENDPOINT = terraform output -raw rds_address

Write-Host "📡 Instance: $APP_INSTANCE_ID" -ForegroundColor Cyan
Write-Host "🗄️  Database: $RDS_ENDPOINT" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ Tunnel créé ! Connectez-vous avec :" -ForegroundColor Green
Write-Host "   mysql -h 127.0.0.1 -P 3306 -u admin -p" -ForegroundColor Yellow
Write-Host ""

aws ssm start-session `
  --target $APP_INSTANCE_ID `
  --document-name AWS-StartPortForwardingSessionToRemoteHost `
  --parameters "{`"host`":[`"$RDS_ENDPOINT`"],`"portNumber`":[`"3306`"],`"localPortNumber`":[`"3306`"]}" `
  --profile galiceau-labs
```

```powershell
.\connect-db.ps1
```

---

## ✅ Avantages de cette solution

- ✅ **Aucune exposition publique** : Ni la DB ni l'EC2 ne sont accessibles depuis Internet
- ✅ **Gratuit** : Les VPC Endpoints coûtent ~$0.01/heure mais SSM est gratuit
- ✅ **Sécurisé** : Tout passe par IAM/SSO et AWS SSM
- ✅ **Pas de gestion de clés SSH** : Pas besoin de bastion ou de clés SSH
- ✅ **Audit** : Toutes les connexions sont loggées dans CloudTrail
- ✅ **Multi-plateforme** : Fonctionne sur Linux, Mac et Windows

---

## 🔧 Dépannage

### L'instance n'apparaît pas dans SSM

Attendez 5-10 minutes après le déploiement, puis vérifiez :

```bash
aws ssm describe-instance-information --profile galiceau-labs
```

### Erreur "TargetNotConnected"

L'instance n'a pas encore enregistré SSM. Vérifiez :
1. L'IAM role est bien attaché à l'instance
2. Les VPC endpoints sont créés
3. Le security group des endpoints autorise le port 443

### Port 3306 déjà utilisé localement

Utilisez un autre port local :

**Linux :**
```bash
aws ssm start-session \
  --target $APP_INSTANCE_ID \
  --document-name AWS-StartPortForwardingSessionToRemoteHost \
  --parameters "{\"host\":[\"$RDS_ENDPOINT\"],\"portNumber\":[\"3306\"],\"localPortNumber\":[\"13306\"]}" \
  --profile galiceau-labs

mysql -h 127.0.0.1 -P 13306 -u admin -p
```

**Mac :**
```bash
aws ssm start-session \
  --target $APP_INSTANCE_ID \
  --document-name AWS-StartPortForwardingSessionToRemoteHost \
  --parameters "{\"host\":[\"$RDS_ENDPOINT\"],\"portNumber\":[\"3306\"],\"localPortNumber\":[\"13306\"]}" \
  --profile galiceau-labs

mysql -h 127.0.0.1 -P 13306 -u admin -p
```

**Windows PowerShell :**
```powershell
aws ssm start-session `
  --target $APP_INSTANCE_ID `
  --document-name AWS-StartPortForwardingSessionToRemoteHost `
  --parameters "{`"host`":[`"$RDS_ENDPOINT`"],`"portNumber`":[`"3306`"],`"localPortNumber`":[`"13306`"]}" `
  --profile galiceau-labs

mysql -h 127.0.0.1 -P 13306 -u admin -p
```

### Erreur "command not found: mysql" (Windows)

Le client MySQL n'est pas dans le PATH. Utilisez le chemin complet :

```powershell
& "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -h 127.0.0.1 -P 3306 -u admin -p
```

Ou ajoutez MySQL au PATH :
1. Recherchez "Variables d'environnement" dans Windows
2. Éditez la variable PATH
3. Ajoutez : `C:\Program Files\MySQL\MySQL Server 8.0\bin`

### Erreur PowerShell "execution policy"

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Erreur "command not found: mysql" (Mac)

Le client MySQL n'est pas dans le PATH. Si installé via Homebrew :

```bash
# Ajouter MySQL au PATH
echo 'export PATH="/usr/local/opt/mysql-client/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Ou pour bash
echo 'export PATH="/usr/local/opt/mysql-client/bin:$PATH"' >> ~/.bash_profile
source ~/.bash_profile

# Vérifier
mysql --version
```

Si vous utilisez MySQL ARM (Apple Silicon M1/M2) :

```bash
echo 'export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Erreur "session-manager-plugin not found" (Mac)

Vérifiez que le plugin est dans le PATH :

```bash
# Vérifier l'installation
ls -la /usr/local/bin/session-manager-plugin

# Si absent, réinstaller
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac/sessionmanager-bundle.zip" -o "sessionmanager-bundle.zip"
unzip sessionmanager-bundle.zip
sudo ./sessionmanager-bundle/install -i /usr/local/sessionmanagerplugin -b /usr/local/bin/session-manager-plugin
```

---

## 🎯 Commandes SQL utiles

Une fois connecté :

```sql
-- Voir l'IP du serveur
SELECT @@hostname;

-- Lister les bases de données
SHOW DATABASES;

-- Utiliser la base testdb
USE testdb;

-- Créer une table de test
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

-- Insérer des données
INSERT INTO users (name, email) VALUES ('John Doe', 'john@example.com');

-- Voir les données
SELECT * FROM users;
```
