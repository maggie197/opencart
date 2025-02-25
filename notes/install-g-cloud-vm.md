# How to install opencart on google cloud virtual machine

Installing OpenCart on Google Cloud requires setting up a virtual machine, configuring a web server, and deploying OpenCart. Here’s a step-by-step guide:

## Step 1: Set Up a Virtual Machine (VM)

1. Go to Google Cloud Console: https://console.cloud.google.com/

2. Navigate to Compute Engine → VM Instances.

3. Click Create Instance.

4. Configure:

* Name: opencart-vm
* Region: Choose the closest one to your audience.
* Machine type: e2-small (for small stores) or higher if needed.
* Boot Disk: Click Change → Select Debian 11 or Ubuntu 22.04 → Increase storage to 20GB+.
* Firewall: Check Allow HTTP and HTTPS traffic.

5.Click Create.

## Step 2: Connect to Your VM

### Option 1. connect in g cloud

1. In the VM Instances list, find your instance.

2. Click SSH to open a terminal.

### Option 2. connect using Git Bash 

### 1. Enable SSH for Your VM 

1. Go to Google Cloud Console → Compute Engine → VM Instances

2. Click on your VM.

3. Under "Connection", check SSH is enabled.

### 2. Manually Create the SSH Directory

Open Git Bash and run:

```
mkdir -p ~/.ssh
chmod 700 ~/.ssh
```

### 3. Generate SSH Keys 

Open Git Bash and run:
```
ssh-keygen -t rsa -b 2048 -C "your-email@example.com"
```
* Press **Enter** to save in ~/.ssh/id_rsa (default).

* Leave passphrase empty (or set one if you prefer).

### 4. Verify the Key Was Created

```
ls ~/.ssh/
```
### 5. Add the SSH Key to Google Cloud

1. Show the public key:
```
cat ~/.ssh/id_rsa.pub
```

2. Copy the output.

3. Go to Google Cloud Console → Compute Engine → Metadata.

4. Click SSH Keys → Add SSH Key.

5. Paste your public key and save.

6. Connect to Your VM Using Git Bash

```
ssh -i ~/.ssh/id_rsa your-user@your-vm-external-ip
```

Check your username in VM metadata: Go to VM details → SSH Keys, and see if a username is assigned.

## Step 3. Install LAMP Stack (Apache, MariaDB, PHP)

Run the following commands inside the VM:

### Update the system

```
sudo apt update && sudo apt upgrade -y
```

### Install Apache 

```
sudo apt install apache2 -y
sudo systemctl enable apache2
sudo systemctl start apache2
```

##### Recommended Option for Package configuration:
##### * Choose: "keep the local version currently installed"
##### (This ensures your SSH settings remain unchanged, avoiding potential issues with remote access.)
<br>
Check if Apache is running:

```
sudo systemctl status apache2
```
Visit http://[EXTERNAL_IP] in your browser (replace [EXTERNAL_IP] with your VM’s external IP from the Compute Engine page).

### Install MariaDB (MySQL Alternative)

```
sudo apt update && sudo apt install mariadb-server -y
```

#### Start and Enable MariaDB

```
sudo systemctl start mariadb
```
Enable it to start on boot:

```
sudo systemctl enable mariadb
```

Check the status:
```
sudo systemctl status mariadb
```
If it's running, you should see "Active: active (running)".

#### Secure MariaDB
Run the security script:

```
sudo mysql_secure_installation

```

Press Enter (if no root password is set).
Answer Y to remove anonymous users, disable remote root login, and improve security.
Set a root password if prompted.


#### Create a Database for OpenCart

Create a Database for OpenCart

* Log into MariaDB:

```
sudo mysql -u root -p
```
* Create a database:

sql 
```
CREATE DATABASE opencart_db;
```
* Create a user and grant privileges: 

sql
```
CREATE USER 'opencart_user'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON opencart_db.* TO 'opencart_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;

```
 Replace 'your_password' with a strong password.

* Test connection:
```
mysql -u opencart_user -p
Then run:
```
sql
```
SHOW DATABASES;
You should see opencart_db.
```

## Install PHP 
1. Install php 8.2 for this version of OpenCart:
```
sudo apt update
sudo apt install software-properties-common -y
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
sudo apt install php8.2 php8.2-cli php8.2-curl php8.2-mbstring php8.2-zip php8.2-mysql php8.2-gd php8.2-xml php8.2-common php8.2-intl php8.2-bcmath -y
```
* Verify PHP Installation:

```
php -v
```
### make red 
If PHP is installed, you’ll see a list of PHP-related packages. If not, continue to Step 2.

2. Check the PHP Binary Location
```
ls /usr/bin/php*
```
3.  Restart Apache
```
sudo systemctl restart apache2
```
Now, try running php -v again, if not, continue step 4. 

4. Update and Upgrade Your System
```
sudo apt update && sudo apt upgrade -y
```
5. Check Your OS Version:
```
lsb_release -a
```
6. Add the Correct PHP Repository
If you're on Debian, install the SURY repository:
```
sudo apt install lsb-release ca-certificates apt-transport-https software-properties-common -y
sudo wget -O /etc/apt/trusted.gpg.d/php-sury.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list
sudo apt update
```
7. Install PHP 8.2 and required extensions:
```
sudo apt install php8.2 php8.2-cli php8.2-common php8.2-curl php8.2-mbstring php8.2-xml php8.2-mysql php8.2-zip php8.2-gd php8.2-intl php8.2-bcmath -y
```
8. Verify Installation
```
php -v
```
9. Restart Apache
```
sudo systemctl restart apache2
```



 ## Step 4: Download and Install OpenCart

 ### Download OpenCart

 ```
 cd /var/www/html
sudo rm index.html  # Remove default Apache page
sudo wget https://github.com/opencart/opencart/releases/download/4.0.2.3/opencart-4.0.2.3.zip
sudo unzip opencart-4.0.2.3.zip
sudo mv opencart-4.0.2.3/upload opencart
sudo chown -R www-data:www-data opencart
sudo chmod -R 755 opencart
```

## Step 5: Configure Apache for OpenCart

Create an Apache virtual host:
```
sudo nano /etc/apache2/sites-available/opencart.conf
```
Add the following configuration:
##### apache
```
<VirtualHost *:80>
    ServerAdmin admin@example.com
    DocumentRoot /var/www/html/opencart/
    ServerName your-domain.com
    <Directory /var/www/html/opencart/>
        Options FollowSymlinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog ${APACHE_LOG_DIR}/opencart_error.log
    CustomLog ${APACHE_LOG_DIR}/opencart_access.log combined
</VirtualHost>
```
Save and exit (CTRL + X, then Y, then Enter)

### Enable the site and restart Apache
```
sudo a2ensite opencart.conf
sudo a2enmod rewrite
sudo systemctl restart apache2
```
## Step 6: Finish Installation via Web Browser