# <span style="color:  #4A90E2;">How to install opencart on google cloud virtual machine uing Ubuntu 22.04 </span>


## <span style="color: #3CB4B3;"> Step 1: Set Up a Virtual Machine (VM)

1. Go to Google Cloud Console: https://console.cloud.google.com/

2. Navigate to Compute Engine → VM Instances.

3. Click Create Instance.

4. Configure:

* Name: opencart-vm
* Region: Choose the closest one to your audience.
* Machine Type: At least e2-medium (2 vCPU, 4GB RAM)
* Boot Disk: Click Change → Select Ubuntu 22.04 LTS → Increase storage to 20GB+.
* Firewall: Enable Allow HTTP and HTTPS traffic.

5. Click Create.

## <span style="color: #3CB4B3;"> Step 2: Connect to Your VM

### Option 1. connect in Google cloud

1. In the VM Instances list, find your instance.

2. Click SSH to open a terminal.

### Option 2. connect using Git Bash 

1. Enable SSH for Your VM 

 Go to Google Cloud Console → Compute Engine → VM Instances

 Click on your VM.

 Under "Connection", check SSH is enabled.

 2. Manually Create the SSH Directory

Open Git Bash and run:

```
mkdir -p ~/.ssh
chmod 700 ~/.ssh
```

3. Generate SSH Keys 

Open Git Bash and run:
```
ssh-keygen -t rsa -b 2048 -C "your-email@example.com"
```
* Press **Enter** to save in ~/.ssh/id_rsa (default).

* Leave passphrase empty (or set one if you prefer).

4. Verify the Key Was Created

```
ls ~/.ssh/
```
5. Add the SSH Key to Google Cloud

* Show the public key:
```
cat ~/.ssh/id_rsa.pub
```

* Copy the output.
* Go to Google Cloud Console → Compute Engine → Metadata.
* Click SSH Keys → Add SSH Key.
* Paste your public key and save.
* Connect to Your VM Using Git Bash

```
ssh -i ~/.ssh/id_rsa your-user@your-vm-external-ip
```

Check your username in VM metadata: Go to VM details → SSH Keys, and see if a username is assigned.

## <span style="color: #3CB4B3;">Step 3. Install LAMP Stack 

Run the following commands to update and install required packages:

```
sudo apt update && sudo apt upgrade -y
sudo apt install apache2 mysql-server php libapache2-mod-php php-mysql php-zip php-gd php-curl php-xml php-mbstring unzip -y
```

Enable Apache and MySQL to start on boot:

```
sudo systemctl enable apache2
sudo systemctl enable mysql
```
## <span style="color: #3CB4B3;">Step 4: Configure MySQL

Secure your MySQL installation:

```
sudo mysql_secure_installation
```

* Set a *root password*
* Remove anonymous users
* Disallow remote root login
* Remove test databases

Then, log in to MySQL and create a database for OpenCart:

```
sudo mysql -u root -p
```

Run the following SQL commands:

```
CREATE DATABASE opencart;
CREATE USER 'opencart_user'@'localhost' IDENTIFIED BY 'StrongPassword123!';
GRANT ALL PRIVILEGES ON opencart.* TO 'opencart_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

 ## <span style="color: #3CB4B3;">Step 5: Download and Install OpenCart

 #### Download OpenCart

Navigate to the web root:

 ```
cd /var/www/html
sudo rm -rf *
sudo wget https://github.com/opencart/opencart/archive/refs/tags/4.0.2.3.zip
sudo unzip 4.0.2.3.zip
sudo mv opencart-4.0.2.3/upload/* .
sudo rm -rf opencart-4.0.2.3 4.0.2.3.zip
```

Set proper permissions:
```
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/
```

Rename configuration files:
```
sudo mv config-dist.php config.php
sudo mv admin/config-dist.php admin/config.php
```

## <span style="color: #3CB4B3;">Step 6: Configure Apache:

Create a new Apache configuration file:
```
sudo nano /etc/apache2/sites-available/opencart.conf
```

Add the following content:
```
<VirtualHost *:80>
    ServerAdmin admin@example.com
    DocumentRoot /var/www/html/
    ServerName your-domain.com

    <Directory /var/www/html/>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

Save and exit (CTRL+X, Y, Enter).

Enable the site and rewrite module:

```
sudo a2ensite opencart
sudo a2enmod rewrite
sudo systemctl restart apache2
```

## <span style="color: #3CB4B3;">Step 7: Finalize OpenCart Installation

1. Visit: http://[EXTERNAL_IP]/opencart/

2. Follow the OpenCart installation wizard:

* Database Settings:
    * Host: localhost
    * Database: opencart
    * Username: opencart_user
    * Password: StrongPassword123!
* Admin Account:
    * Set up an admin username & password

3. After installation, login to admin and delete the install directory

### Note:
If you have an ephemeral (non-static) IP addresses. IP address will have to be updated in congif.php files:

To check for files:
```
ls /var/www/html/
```

Edit file:
```
sudo nano /var/www/html/config.php
sudo nano /var/www/html/admin/config.php
```
