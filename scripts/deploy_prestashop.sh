#!/bin/bash
set -ex

source "$(dirname "$0")/.env"

# 1. Base de datos
mysql -u root -p"${DB_ROOT_PASSWORD}" -e "DROP DATABASE IF EXISTS ${DB_NAME}; CREATE DATABASE ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}'; GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost'; FLUSH PRIVILEGES;"

# 2. Preparar código fuente desde el ZIP local
rm -rf /tmp/ps_extract /tmp/ps_final && mkdir -p /tmp/ps_extract /tmp/ps_final
unzip -q -o /home/miriam/descargas_ps/PrestaShop-${PS_VERSION}.zip -d /tmp/ps_extract

SRC_DIR="/tmp/ps_extract/PrestaShop-${PS_VERSION}"
if [ ! -d "$SRC_DIR" ]; then
    SRC_DIR="/tmp/ps_extract"
fi
if [ -f "$SRC_DIR/prestashop.zip" ]; then
    unzip -q -o "$SRC_DIR/prestashop.zip" -d /tmp/ps_final
else
    cp -r "$SRC_DIR"/* /tmp/ps_final/
fi

# 3. Copia al directorio raíz de Apache
rm -rf /var/www/html/*
cp -r /tmp/ps_final/* /var/www/html/
chown -R www-data:www-data /var/www/html

# 4. Instalar Composer y dependencias si existe install-dev
if [ -d "/var/www/html/install" ]; then
    INSTALL_DIR="/var/www/html/install"
elif [ -d "/var/www/html/install-dev" ]; then
    INSTALL_DIR="/var/www/html/install-dev"
    if ! command -v composer >/dev/null 2>&1; then
        curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
    fi
    COMPOSER_ALLOW_SUPERUSER=1 composer install --working-dir=/var/www/html --no-interaction --prefer-dist
else
    echo "ERROR: No se encuentra el directorio install ni install-dev"
    exit 1
fi

# 5. Instalación por CLI
cd "$INSTALL_DIR"
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
  --ssl=${PS_SSL}

# 6. Limpieza: eliminar carpetas de instalación
rm -rf /var/www/html/install /var/www/html/install-dev
chown -R www-data:www-data /var/www/html
systemctl restart apache2

echo "PrestaShop instalado. Nombre del back office: $(ls /var/www/html | grep '^admin')"
