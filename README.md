# Implantación de PrestaShop

## 1. Introducción

En esta práctica se instala la aplicación web **PrestaShop** sobre una pila LAMP, automatizando todo el proceso con scripts de Bash.

## 2. Preparación de la máquina virtual

Utilizo la máquina **Server-IAW** de VirtualBox, con Ubuntu de 64 bits.

![Captura 1](img/Captura%20de%20pantalla%202026-11-18%20101803.png)


La máquina tiene **4096 MB de RAM**, superior a los 2 GB mínimos que necesita PrestaShop.

![Captura 2](img/Captura%20de%20pantalla%202026-11-18%20095638.png)

### Configuración de red

El adaptador de red se configura en **modo puente** para que la máquina obtenga una IP de la red local y se pueda acceder a ella desde el equipo anfitrión.

![Captura 3](img/Captura%20de%20pantalla%202026-11-18%20095658.png)

Se comprueba la IP de la máquina virtual: **192.168.1.11**.

![Captura 4](img/Captura%20de%20pantalla%202026-11-19%20203440.png)

Desde el equipo anfitrión se comprueba la conectividad con <code>ping</code>.

![Captura 5](img/Captura%20de%20pantalla%202026-11-19%20203606.png)

## 3. Instalación de la pila LAMP y comprobación de requisitos

Se ejecuta <code>install_lamp.sh</code> para instalar Apache, MySQL, PHP y sus extensiones, ajustar <code>php.ini</code> y descargar <code>phppsinfo.php</code> en <code>/var/www/html/phppsinfo/</code>.

1. Accedemos desde el navegador a <code>http://192.168.1.11/phppsinfo/phppsinfo.php</code> e iniciamos sesión con las credenciales por defecto (<code>prestashop</code> / <code>prestashop</code>):

![Captura 6](img/Captura%20de%20pantalla%202026-11-19%20203011.png)

2. Comprobamos en las tablas de <code>phppsinfo</code> que los ajustes de PHP (<code>memory_limit = 256M</code>, <code>max_input_vars = 5000</code>, <code>post_max_size = 128M</code>, <code>upload_max_filesize = 128M</code>) y los requisitos necesarios aparecen en verde:

![Captura 7](img/Captura%20de%20pantalla%202026-11-19%20203027.png)

## 4. Despliegue de PrestaShop (Código fuente e instalación)

En este apartado se utiliza la última versión disponible de PrestaShop (**9.2.1**), obtenida desde el repositorio oficial de GitHub 

1. Configuro las variables de entorno en el archivo <code>.env</code> (<code>DOMAIN=192.168.1.11</code>, <code>PS_VERSION=9.2.1</code>, credenciales de base de datos y datos del administrador).

![Captura 8](img/Captura%20de%20pantalla%202026-11-20%20135440.png)

2. Ejecuto el script <code>deploy_prestashop.sh</code> para crear la base de datos <code>prestashop</code> y el usuario <code>ps_user</code> en MySQL, descomprimir el código fuente en <code>/var/www/html</code>, lanzar la instalación automatizada por línea de comandos (<code>index_cli.php</code>) y eliminar el directorio <code>install</code> por seguridad.

```bash
sudo ./deploy_prestashop.sh
```

![Captura 9](img/Captura%20de%20pantalla%202026-11-20%20135705.png)


## 5. Comprobación y resultado final

1. Accedo desde el navegador al **Front Office** a través de <code>http://192.168.1.11</code> para verificar que PrestaShop carga correctamente.

![Captura 10](ruta_a_tu_captura_10.png)

2. Accedo al **Back Office** (panel de administración) usando la ruta generada e inicio sesión con las credenciales configuradas en <code>.env</code>.

![Captura 11](ruta_a_tu_captura_11.png)


## 6. Comprobación de memoria RAM e IP de la máquina virtual

1. Arranco la máquina virtual en VirtualBox y abro la terminal de Ubuntu.
2. Ejecuto <code>free -h</code> y <code>ip -br a</code> para comprobar la RAM total asignada y la dirección IP activa en la red.

![Captura 10](img/Captura%20de%20pantalla%202026-11-20%20170516.png)

Como vemos tiene mas de 2GB de memoria.

## 7. Sistema operativo base equivalente a Ubuntu Server AMI

1. En lugar de seleccionar una Community AMI de Ubuntu Server en AWS EC2, se usa una máquina virtual (IP asignada <code>192.168.1.11/24</code> en <code>enp0s3</code>).
2. Compruebo la versión exacta de Ubuntu instalada ejecutando <code>cat /etc/os-release</code>

![Captura 11](img/Captura%20de%20pantalla%202026-11-20%20170843.png)

La salida muestra <code>PRETTY_NAME="Ubuntu 26.04.1 LTS"</code> (<code>VERSION_ID="26.04"</code>).

## 8. Configuración de puertos de red: SSH, HTTP y HTTPS (Tarea 3)

1. Como trabajo en una máquina virtual local con adaptador puente en lugar de un *Security Group* de AWS EC2, configuro los puertos directamente con <code>ufw</code> en Ubuntu.
2. Permito el tráfico entrante por TCP para <code>22/tcp</code> (SSH), <code>80/tcp</code> (HTTP) y <code>443/tcp</code> (HTTPS) y activo el cortafuegos.
3. Verifico el estado del cortafuegos y los sockets escuchando con <code>sudo ufw status verbose &amp;&amp; ss -tulpn | grep -E ':22|:80|:443'</code>.

![Captura 12](img/Captura%20de%20pantalla%202026-11-20%20171449.png)

![Captura 13](img/Captura%20de%20pantalla%202026-11-20%20171753.png)


<code>Status: active</code> con las reglas <code>22/tcp</code>, <code>80/tcp</code> y <code>443/tcp</code> permitidas (<code>ALLOW IN</code>) y los servicios escuchando en el sistema.

## 9. Creación de par de claves SSH y conexión con la máquina virtual (Tarea 4)

1. Como trabajo en local con VirtualBox en lugar de generar un par de claves <code>.pem</code> en AWS EC2, creo la carpeta <code>.ssh</code> en mi equipo Windows y genero el par de claves SSH (privada <code>id_ed25519_prestashop</code> y pública <code>id_ed25519_prestashop.pub</code>):

```cmd
mkdir "%USERPROFILE%\.ssh"
ssh-keygen -t ed25519 -f "%USERPROFILE%\.ssh\id_ed25519_prestashop" -N ""
```

![Captura 14](img/Captura%20de%20pantalla%202026-11-20%20173625.png)

Envío la clave pública a la máquina virtual (miriam@192.168.1.11) para guardarla en ~/.ssh/authorized_keys y configuro los permisos necesarios (700 en ~/.ssh y 600 en authorized_keys):

![Captura 15](img/Captura%20de%20pantalla%202026-11-20%20173818.png)

Acepto la huella del host (yes) al conectar por primera vez y pruebo el acceso remoto usando mi clave privada:

![Captura 16](img/Captura%20de%20pantalla%202026-11-20%20173951.png)

inicio sesión directamente en la terminal de la máquina virtual (miriam@miriam:~$, sobre Ubuntu 26.04.1 LTS con IP 192.168.1.11) sin que me vuelva a pedir contraseña.

## 10. Dirección IP fija / equivalente a IP elástica en la máquina virtual (Tarea 5)

1. En AWS EC2 se asigna una *Elastic IP* para mantener una dirección IP pública constante; en mi entorno local con VirtualBox (Adaptador puente) utilizo el mismo enfoque para mantener la dirección **<code>192.168.1.11</code>** en la interfaz <code>enp0s3</code> (<code>08:00:27:c8:ad:d6</code>) de **Ubuntu 26.04.1 LTS**.
2. Reviso la configuración de red con <code>sudo ls -la /etc/netplan/</code> y <code>sudo cat /etc/netplan/&#42;.yaml</code>, comprobando que el archivo <code>00-installer-config.yaml</code> pertenecía a <code>root</code> y tenía <code>dhcp4: true</code>.

![Captura 17](img/Captura%20de%20pantalla%202026-11-20%20174715.png)

3. Configuro la IP estática <code>192.168.1.11/24</code> en <code>/etc/netplan/00-installer-config.yaml</code>

![Captura 18](img/Captura%20de%20pantalla%202026-11-20%20175233.png)

la interfaz <code>enp0s3</code> mantiene <code>192.168.1.11/24</code> y la conexión SSH desde Windows sigue operativa sin cambiar de IP.


## 11. Registro de nombre de dominio gratuito 

1. Accedo a **No-IP** e inicio sesión en mi cuenta.

![Captura 19](img/Captura%20de%20pantalla%202026-11-20%20175906.png)

2. Creo el nombre de host <code>prestashop-miriam.bounceme.net</code> bajo la zona <code>bounceme.net</code> como registro de tipo <code>A</code> apuntando a <code>45.13.201.205</code> (TTL <code>60</code>).

![Captura 20](img/Captura%20de%20pantalla%202026-11-20%20180003.png)

3. Compruebo la resolución del nombre de dominio mediante <code>nslookup prestashop-miriam.bounceme.net</code>.

![Captura 21](img/Captura%20de%20pantalla%202026-11-20%20180831.png)

el registro aparece activo en No-IP (<code>prestashop-miriam.bounceme.net</code>, tipo <code>A</code>, contenido <code>45.13.201.205</code>) y resuelve correctamente por DNS.


## 12. Configuración de registros DNS hacia la dirección IP (Tarea 7)

1. En VirtualBox (Ubuntu 26.04.1 LTS en <code>192.168.1.11</code>), configuro el registro <code>A</code> de <code>prestashop-miriam.bounceme.net</code> en No-IP apuntando a <code>45.13.201.205</code>.
2. Compruebo la resolución del nombre de dominio desde la terminal mediante <code>nslookup prestashop-miriam.bounceme.net</code>.

![Captura 22](img/Captura%20de%20pantalla%202026-11-20%20180831.png)

<code>nslookup</code> devuelve <code>prestashop-miriam.bounceme.net</code> resolviendo hacia <code>45.13.201.205</code> a través del resolvedor <code>127.0.0.53</code>.

## 13. Instalación automatizada de LAMP y phpMyAdmin mediante script

1. Me conecto por SSH desde Windows a mi máquina virtual Ubuntu 26.04.1 LTS (<code>192.168.1.11</code>) y accedo a <code>~/Instalar-Prestashop-en-una-instancia-AWS/scripts</code> para preparar y ejecutar <code>install_lamp.sh</code> (<code>chmod +x install_lamp.sh</code> y <code>sudo ./install_lamp.sh</code>), automatizando la instalación de Apache, MySQL, PHP 8.5 con sus extensiones, los ajustes de <code>php.ini</code>, el *virtual host* (<code>000-default.conf</code>), **phpMyAdmin** y PhpPsInfo.
2. Durante el proceso resuelvo el aviso de autenticación de <code>root@localhost</code> en MySQL aplicando <code>caching_sha2_password</code> y completo las opciones interactivas de **phpMyAdmin** (<code>apache2</code> y <code>dbconfig-common</code>), así como los pasos finales de descarga de PhpPsInfo, permisos sobre <code>/var/www/html</code> y reinicio de Apache.
3. Compruebo el estado de los servicios con <code>systemctl status apache2 mysql --no-pager</code> y verifico el acceso web a **phpMyAdmin**, eliminando después <code>/var/www/html/phppsinfo</code> al terminar la comprobación.

![Captura 23](img/Captura%20de%20pantalla%202026-11-20%20190159.png)

![Captura 24](img/Captura%20de%20pantalla%202026-11-20%20185847.png)

<code>apache2.service</code> y <code>mysql.service</code> quedan en estado <code>active (running)</code> y phpMyAdmin responde correctamente en el navegador.


## 14. Instalación de Certbot y configuración SSL/TLS

1. Instalo y compruebo <code>certbot</code> y <code>python3-certbot-apache</code>, verificando que el temporizador <code>certbot.timer</code> está activo (<code>certbot --version</code> y <code>sudo systemctl status certbot.timer --no-pager</code>).


![Captura 25](img/Captura%20de%20pantalla%202026-11-21%20182032.png)

2. Solicito el certificado de Let's Encrypt para <code>prestashop-miriam.bounceme.net</code> mediante validación HTTP-01 (<code>sudo certbot --apache -d prestashop-miriam.bounceme.net</code>), obteniendo *timeout* en el puerto <code>80</code> hacia <code>45.13.201.205</code>, mientras compruebo que Apache responde en local (<code>curl -I http://192.168.1.11</code> -> <code>HTTP/1.1 200 OK</code>).


![Captura 26](img/Captura%20de%20pantalla%202026-11-21%20182140.png)

3. Pruebo el reto alternativo DNS-01 (<code>sudo certbot certonly --manual --preferred-challenges dns -d prestashop-miriam.bounceme.net</code>) y compruebo con <code>dig @8.8.8.8 +short TXT _acme-challenge.prestashop-miriam.bounceme.net</code> que no aparece el registro <code>TXT</code> por las limitaciones del subdominio gratuito <code>&#42;.bounceme.net</code> en No-IP.


![Captura 27](img/Captura%20de%20pantalla%202026-11-21%20182555.png)

4. Para activar HTTPS (<code>443</code>) en el entorno de pruebas, ejecuto <code>sudo ./setup_letsencrypt_https.sh</code> y verifico la conexión segura y el certificado generado con <code>curl -kI https://192.168.1.11</code> y <code>openssl x509 -in /etc/ssl/certs/prestashop.crt -noout -subject -dates</code>.

![Captura 28](img/Captura%20de%20pantalla%202026-11-21%20182833.png)

![Captura 29](img/Captura%20de%20pantalla%202026-11-21%20182843.png)


## Ejercicio 15: Script de automatización de la instalación y configuración de PrestaShop

1. Redacto el script de Bash <code>deploy_prestashop.sh</code> (junto con el archivo <code>.env</code> de configuración) en el repositorio de GitHub (<code>Instalar-Prestashop-en-una-instancia-AWS/scripts/</code>) para automatizar la preparación de la base de datos, extracción de PrestaShop, permisos, instalación por CLI y limpieza posterior, dejando su ejecución pendiente para el final de la práctica.

```bash
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"

if [ ! -f "${ENV_FILE}" ]; then
    echo "ERROR: No se encuentra el archivo .env en ${SCRIPT_DIR}"
    exit 1
fi

set -a
source "${ENV_FILE}"
set +a

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

systemctl start mariadb 2>/dev/null || systemctl start mysql 2>/dev/null || true

mysql -u root -p"${DB_ROOT_PASSWORD}" <<SQL
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';
ALTER USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
SQL

if [ ! -f "${ZIP_PATH}" ]; then
    echo "ERROR: No se encuentra el archivo ${ZIP_PATH}"
    exit 1
fi

SRC_DIR="/tmp/ps_extract"
rm -rf "${SRC_DIR}" /tmp/ps_final
mkdir -p "${SRC_DIR}" /tmp/ps_final
unzip -q "${ZIP_PATH}" -d "${SRC_DIR}"

if [ -f "${SRC_DIR}/prestashop.zip" ]; then
    unzip -o -q "${SRC_DIR}/prestashop.zip" -d /tmp/ps_final
else
    cp -r "${SRC_DIR}/." /tmp/ps_final/
fi

mkdir -p "${WEB_ROOT}"
rm -rf "${WEB_ROOT:?}"/*
cp -r /tmp/ps_final/. "${WEB_ROOT}/"
chown -R www-data:www-data "${WEB_ROOT}"

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

rm -rf "${WEB_ROOT}/install" "${WEB_ROOT}/install-dev"
rm -rf /tmp/ps_extract /tmp/ps_final
chown -R www-data:www-data "${WEB_ROOT}"
systemctl restart apache2
```
