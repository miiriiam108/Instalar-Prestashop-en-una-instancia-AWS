#!/bin/bash
# Descarga e instala PrestaShop desde CLI en /var/www/html
set -ex

source "$(dirname "$0")/.env"

# 1. Base de datos
mysql -u root -p"${DB_ROOT_PASSWORD}" <<SQL
DROP DATABASE IF EXISTS \`${DB_NAME}\`;
CREATE DATABASE \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
SQL

# 2. Descarga del código fuente
cd /tmp
rm -rf ps_download && mkdir ps_download && cd ps_download
wget -q "https://github.com/PrestaShop/PrestaShop/releases/download/${PS_VERSION}/prestashop_${PS_VERSION}.zip"
unzip -q "prestashop_${PS_VERSION}.zip"   # contiene prestashop.zip

# 3. Copia al directorio raíz de Apache
rm -f /var/www/html/index.html
unzip -q -o prestashop.zip -d /var/www/html
chown -R www-data:www-data /var/www/html

# 4. Instalación por CLI
cd /var/www/html/install
sudo -u www-data php index_cli.php \
  --domain="${DOMAIN}" \
  --db_server=localhost \
  --db_name="${DB_NAME}" \
  --db_user="${DB_USER}" \
  --db_password="${DB_PASSWORD}" \
  --prefix="${PS_DB_PREFIX}" \
  --email="${PS_ADMIN_EMAIL}" \
  --password="${PS_ADMIN_PASSWORD}" \
  --language="${PS_LANGUAGE}" \
  --country="${PS_COUNTRY}" \
  --ssl=1

# 5. Limpieza: el directorio install debe eliminarse
rm -rf /var/www/html/install
chown -R www-data:www-data /var/www/html
systemctl restart apache2

echo "PrestaShop instalado. Nombre del back office: $(ls /var/www/html | grep '^admin')"
