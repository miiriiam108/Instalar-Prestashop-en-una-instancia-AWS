#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"

if [ ! -f "${ENV_FILE}" ]; then
    echo "ERROR: No se encuentra el archivo .env en ${SCRIPT_DIR}"
    exit 1
fi

# Cargar variables de configuración
set -a
source "${ENV_FILE}"
set +a

# Valores por defecto si no están definidos en .env
DOMAIN="${DOMAIN:-192.168.1.11}"
PS_VERSION="${PS_VERSION:-9.2.1}"
PS_SSL="${PS_SSL:-0}"
PS_LANGUAGE="${PS_LANGUAGE:-es}"
PS_COUNTRY="${PS_COUNTRY:-es}"
PS_DB_PREFIX="${PS_DB_PREFIX:-ps_}"
DB_NAME="${DB_NAME:-prestashop}"
DB_USER="${DB_USER:-ps_user}"
DB_PASSWORD="${DB_PASSWORD:-8888}"
DB_ROOT_PASSWORD="${DB_ROOT_PASSWORD:-8888}"
PS_ADMIN_EMAIL="${PS_ADMIN_EMAIL:-admin@example.com}"
PS_ADMIN_PASSWORD="${PS_ADMIN_PASSWORD:-PrestaShop123!}"
ZIP_PATH="${ZIP_PATH:-/home/miriam/descargas_ps/PrestaShop-${PS_VERSION}.zip}"
WEB_ROOT="/var/www/html"

echo "=== 1. Comprobando servicios y preparando base de datos ==="
systemctl start mariadb 2>/dev/null || systemctl start mysql 2>/dev/null || true

mysql -u root -p"${DB_ROOT_PASSWORD}" <<SQL
DROP DATABASE IF EXISTS \`${DB_NAME}\`;
CREATE DATABASE \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';
ALTER USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
SQL

echo "=== 2. Extrayendo el código fuente de PrestaShop ${PS_VERSION} ==="
if [ ! -f "${ZIP_PATH}" ]; then
    echo "ERROR: No se encuentra el archivo ZIP en ${ZIP_PATH}"
    exit 1
fi

rm -rf /tmp/ps_extract /tmp/ps_final
mkdir -p /tmp/ps_extract /tmp/ps_final
unzip -q -o "${ZIP_PATH}" -d /tmp/ps_extract

SRC_DIR="/tmp/ps_extract/PrestaShop-${PS_VERSION}"
if [ ! -d "${SRC_DIR}" ]; then
    SRC_DIR="/tmp/ps_extract"
fi

if [ -f "${SRC_DIR}/prestashop.zip" ]; then
    unzip -q -o "${SRC_DIR}/prestashop.zip" -d /tmp/ps_final
else
    cp -r "${SRC_DIR}/." /tmp/ps_final/
fi

echo "=== 3. Copiando archivos a ${WEB_ROOT} y ajustando permisos ==="
rm -rf "${WEB_ROOT:?}"/*
cp -r /tmp/ps_final/. "${WEB_ROOT}/"
chown -R www-data:www-data "${WEB_ROOT}"

echo "=== 4. Resolviendo dependencias con Composer (si aplica) ==="
if [ -d "${WEB_ROOT}/install" ]; then
    INSTALL_DIR="${WEB_ROOT}/install"
elif [ -d "${WEB_ROOT}/install-dev" ]; then
    INSTALL_DIR="${WEB_ROOT}/install-dev"
    if ! command -v composer >/dev/null 2>&1; then
        curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
    fi
    COMPOSER_ALLOW_SUPERUSER=1 composer install --working-dir="${WEB_ROOT}" --no-interaction --prefer-dist
else
    echo "ERROR: No se encontró el directorio 'install' ni 'install-dev' en ${WEB_ROOT}"
    exit 1
fi

echo "=== 5. Ejecutando instalación de PrestaShop por CLI ==="
cd "${INSTALL_DIR}"
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
  --ssl="${PS_SSL}"

echo "=== 6. Limpieza post-instalación y reinicio de Apache ==="
rm -rf "${WEB_ROOT}/install" "${WEB_ROOT}/install-dev"
rm -rf /tmp/ps_extract /tmp/ps_final
chown -R www-data:www-data "${WEB_ROOT}"
systemctl restart apache2

ADMIN_DIR=$(ls -1 "${WEB_ROOT}" | grep '^admin' | head -n 1 || true)
echo "=========================================================="
echo "PrestaShop ${PS_VERSION} instalado correctamente."
echo "URL tienda: http://${DOMAIN}/"
if [ -n "${ADMIN_DIR}" ]; then
    echo "Directorio Back Office: /${ADMIN_DIR}/"
fi
echo "=========================================================="
