## Install OpenCart on Google Cloud using Terraform

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
    sudo rm -rf opencart-4.0.1.0.zip
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

8. Navigate to your OpenCart Files and rename config files:
```
 cd /var/www/html/

```

```
sudo mv config-dist.php config.php
sudo mv admin/config-dist.php admin/config.php

```

10. Finalize OpenCart Installation

    1. Visit: http://[EXTERNAL_IP]/install/
    
If missing any required PHP extensions for OpenCart. You need to install and enable them:

  * Update packege list, install missing PHP extensions and restart Apache:
    ```
    sudo apt update
    sudo apt install -y php-gd php-zip
    sudo systemctl restart apache2

    ```
    2. Follow the OpenCart installation wizard:

    * Database Settings:
      * Host: localhost
      * Database: opencart
      * Username: opencart_user
      * Password: StrongPassword123!
  * Admin Account:
      * Set up an admin username & password

  3. After installation, login to admin and delete the install directory
