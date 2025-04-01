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

</details>

<summary> <h3> Connect via SFTP to modify files using FileZilla</h3> </summary>

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

<br> </br>

# <span style="color:  #4A90E2;">Install OpenCart on Google Cloud using Terraform </span>


### 1. Create a Terraform configuration file

Create a directory for your Terraform project and inside it, create a main.tf file. This file will define your resources.

```
provider "google" {
  project = "name-project"    # project name
  region  = "region"      # add region  
  zone    = "zone"    # add zone
}

resource "google_compute_instance" "opencart_vm" {
  name         = "opencart-vm"
  machine_type = "e2-medium"
  zone         = "zone"   # ad zone

  tags = ["http-server", "https-server", "ssh-server"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"  # Use Ubuntu 22.04 LTS
      size  = 20
      type  = "pd-balanced"
    }
  }

  network_interface {
    network = "default"
    access_config {}  
  }

  metadata = {
    enable-osconfig = "TRUE"
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]

  lifecycle {
    ignore_changes = [name]
  }
}

```

Note: If you have previously created the rule manually or if it was created by a previous Terraform run. You'll need to delete the existing firewall rule:

```

gcloud compute firewall-rules delete allow-ssh --quiet

```

### 2. Initialize Terraform

Run the following commands in your project directory to initialize Terraform and authenticate with Google Cloud:

```
terraform init

```

### 3. Apply Terraform Configuration

Run the following command to create the resources defined in main.tf:

```
terraform apply

```

Confirm actions, Enter value: yes

### 4. Connect to the VM

```
gcloud compute ssh opencart-vm --zone=zone

```
or using git bash terminal:

```
ssh -i ~/.ssh/id_rsa username@External IP
```

### 5. Install OpenCart on the VM

Once you're logged into the instance, follow these steps to install OpenCart:

1. Update your package list:
    
    ```
    sudo apt-get update
    
    ```
    
2. Install Apache, PHP, and other required packages:

    ```
    sudo apt-get install -y apache2 php php-mysqli php-curl php-xml php-mbstring unzip

    ```

3. Install MySQL:

    ```
    sudo apt-get install -y mysql-server

4. Download OpenCart:
  * Download file 

    ```
    wget https://github.com/opencart/opencart/releases/download/4.0.1.0/opencart-4.0.1.0.zip

    ```
  * Unzip file:
  ```
    sudo unzip opencart-4.0.1.0.zip -d /var/www/html/

  ```


6. Set up database for OpenCart: Log into MySQL:

  * Log into MySQL:

    ```
    sudo mysql -u root -p

    ```

  * Create a database and user for OpenCart:

    ```
    CREATE DATABASE opencart;
    CREATE USER 'opencartuser'@'localhost' IDENTIFIED BY 'yourpassword';
    GRANT ALL PRIVILEGES ON opencart.* TO 'opencart_user'@'localhost';
    FLUSH PRIVILEGES;
    EXIT;
    ```

7. Configure OpenCart 

    ```
    sudo chown -R www-data:www-data /var/www/html
    sudo chmod -R 755 /var/www/html

    ```

8. If your OpenCart Files are located in upload move upload content to html:
```
sudo mv /var/www/html/upload/* /var/www/html/
```
9. Navigate to your OpenCart Files and rename config files:

```
 cd /var/www/html/

```

```
sudo mv config-dist.php config.php
sudo mv admin/config-dist.php admin/config.php

```
10. If missing any required PHP extensions for OpenCart. You need to install and enable them:

  * Update packege list, install missing PHP extensions and restart Apache:
    ```
    sudo apt update
    sudo apt install -y php-gd php-zip
    sudo systemctl restart apache2

    ```
11. Finalize OpenCart Installation

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
