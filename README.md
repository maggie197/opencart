<span style="font-size: 2em; color: #4A90E2; font-weight: bold;">How to Deploy OpenCart on Google Cloud</span>

<details>
  <summary> <span style="font-size: 1.7em; color: #4abde2; font-weight: bold;"> Deploy OpenCart Manually</span> </summary>

## <span style="color: #147b7b;"> Step 1: Set Up a Virtual Machine (VM)

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

## <span style="color: #147b7b;"> Step 2: Connect to Your VM

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

## <span style="color: #147b7b;">Step 3. Install LAMP Stack 

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
## <span style="color: #147b7b;">Step 4: Configure MySQL

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

 ## <span style="color: #147b7b;">Step 5: Download and Install OpenCart

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

## <span style="color: #147b7b;">Step 6: Configure Apache:

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

## <span style="color: #147b7b;">Step 7: Finalize OpenCart Installation

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

## <summary> <h3> <span style="color: #588474;"> Connect via SFTP to modify files using FileZilla </span> </h3> </summary>

 Step 1: Install FileZilla (SFTP Client)

 Step 2: Get Your VM External IP and Key File
 
 1. Go to Google Cloud Console → Compute Engine → VM instances.
 2. Find your OpenCart VM and note down the External IP
 3. Click SSH → View gcloud command (top-right).
 4. Copy the path to your private key file. It usually looks like:
```
/home/your-username/.ssh/google_compute_engine
```

Step 3: Connect to Your VM Using FileZilla

1. Open FileZilla → Click File → Site Manager.

2. Create a new site and fill in the following:
   * Protocol: SFTP - SSH File Transfer Protocol
   * Host: <YOUR_VM_EXTERNAL_IP>
   * Port: 22
   * Logon Type: Key file
   * User: your-username
   * Key file: Browse to your private key file (e.g., /home/your-username/.ssh/google_compute_engine)
 3. Click Connect.

</details>


<details>
  <summary> <span style="font-size: 1.7em; color: #4abde2; font-weight: bold;"> Deploy OpenCart using Terraform </span> </summary>

## <span style="color: #147b7b;"> Step 1: Create a Terraform configuration file

Create a directory for your Terraform project and inside it, create a main.tf file. This file will define your resources.

```
provider "google" {
  project = "your-id-project"
  region  = "europe-west2"
  zone    = "europe-west2-b"
}

resource "google_compute_instance" "instancevm" {
  name         = "instancevm"
  machine_type = "e2-medium"
  zone         = "your-zone"   

  tags = ["http-server", "https-server", "ssh-server"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"  
      size  = 20
      type  = "pd-balanced"
    }
  }

  network_interface {
    network = "default"
    access_config {} # This enables external IP access
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    sudo apt update && sudo apt upgrade -y
    sudo apt install apache2 mysql-server php libapache2-mod-php php-mysql php-zip php-gd php-curl php-xml php-mbstring unzip -y

    # Enable Apache and MySQL to start on boot
    sudo systemctl enable apache2
    sudo systemctl enable mysql

    # Secure MySQL installation
    sudo mysql_secure_installation <<EOF

    Y
    StrongPassword123!
    Y
    Y
    Y
    Y
    EOF

    # Configure MySQL
    sudo mysql -u root -pStrongPassword123! <<EOF
    CREATE DATABASE opencart;
    CREATE USER 'opencart_user'@'localhost' IDENTIFIED BY 'StrongPassword123!';
    GRANT ALL PRIVILEGES ON opencart.* TO 'opencart_user'@'localhost';
    FLUSH PRIVILEGES;
    EXIT;
    EOF

    # Download and install OpenCart
    cd /var/www/html
    sudo rm -rf *
    sudo wget https://github.com/opencart/opencart/archive/refs/tags/4.0.2.3.zip
    sudo unzip 4.0.2.3.zip
    sudo mv opencart-4.0.2.3/upload/* .
    sudo rm -rf opencart-4.0.2.3 4.0.2.3.zip

    # Set proper permissions
    sudo chown -R www-data:www-data /var/www/html/
    sudo chmod -R 755 /var/www/html/

    # Rename configuration files
    sudo mv config-dist.php config.php
    sudo mv admin/config-dist.php admin/config.php

    # Configure Apache
    sudo bash -c 'cat <<EOF > /etc/apache2/sites-available/opencart.conf
    <VirtualHost *:80>
        ServerAdmin admin@example.com
        DocumentRoot /var/www/html/
        ServerName your-domain.com

        <Directory /var/www/html/>
            AllowOverride All
            Require all granted
        </Directory>

    </VirtualHost>
    EOF'

    # Enable Apache site and rewrite module
    sudo a2ensite opencart
    sudo a2enmod rewrite
    sudo systemctl restart apache2
  EOT
}

```
## <span style="color: #147b7b;"> Step 2: Initialize Terraform

Run the following commands in your project directory to initialize Terraform and authenticate with Google Cloud:

```
terraform init

```

## <span style="color: #147b7b;"> Step 3. Apply Terraform Configuration

Run the following command to create the resources defined in main.tf:

```
terraform apply

```

Confirm actions, Enter value: yes

## <span style="color: #147b7b;"> Step 4. Finalize OpenCart Installation


  1. Visit: http://[EXTERNAL_IP]/install/
    
  2. Follow the OpenCart installation wizard:

  * Database Settings:
    * Host: localhost
    * Database: opencart
    * Username: opencart_user
    * Password: StrongPassword123!
  * Admin Account:
    * Set up an admin username & password

  3. After installation, login to admin and delete the install directory
