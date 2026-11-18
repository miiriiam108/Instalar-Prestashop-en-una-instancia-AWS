#!/bin/bash
# Instalación de la pila LAMP + extensiones PHP para PrestaShop + phpMyAdmin
set -ex

source "$(dirname "$0")/.env"

export DEBIAN_FRONTEND=noninteractive
apt update
apt upgrade -y

# Apache
apt install -y apache2 unzip curl wget
a2enmod rewrite headers

# MySQL
apt install -y mysql-server

# PHP y extensiones requeridas/recomendadas por PrestaShop
apt install -y php libapache2-mod-php php-mysql php-curl php-gd php-intl \
  php-mbstring php-xml php-zip php-bcmath php-imagick

# Ajustes de php.ini (se detecta la versión instalada)
PHP_INI=$(ls /etc/php/*/apache2/php.ini | head -n 1)
sed -i "s/^memory_limit = .*/memory_limit = ${PHP_MEMORY_LIMIT}/" "$PHP_INI"
sed -i "s/^;\?max_input_vars = .*/max_input_vars = ${PHP_MAX_INPUT_VARS}/" "$PHP_INI"
sed -i "s/^post_max_size = .*/post_max_size = ${PHP_POST_MAX_SIZE}/" "$PHP_INI"
sed -i "s/^upload_max_filesize = .*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" "$PHP_INI"

# Virtual host con AllowOverride All
cp "$(dirname "$0")/../conf/000-default.conf" /etc/apache2/sites-available/000-default.conf

# Contraseña de root de MySQL (por defecto usa auth_socket)
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${DB_ROOT_PASSWORD}'; FLUSH PRIVILEGES;"

# phpMyAdmin (instalación desatendida)
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password ${PMA_APP_PASSWORD}" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password ${DB_ROOT_PASSWORD}" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password ${PMA_APP_PASSWORD}" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
apt install -y phpmyadmin

# PhpPsInfo (credenciales por defecto: prestashop / prestashop)
# IMPORTANTE: elimínalo cuando termines la comprobación.
mkdir -p /var/www/html/phppsinfo
curl -fsSL "$PHPPSINFO_URL" -o /var/www/html/phppsinfo/phppsinfo.php

chown -R www-data:www-data /var/www/html
systemctl restart apache2
