provider "google" {
  project = "megija-terraform-project"
  region  = "europe-west2"
  zone    = "europe-west2-b"
}

resource "google_compute_instance" "instancevm" {
  name         = "instancevm"
  machine_type = "e2-medium"
  zone         = "europe-west2-b"   # ad zone

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


