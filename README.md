# Implantación de PrestaShop

## 1. Introducción

En esta práctica se instala la aplicación web **PrestaShop** sobre una pila LAMP, automatizando todo el proceso con scripts de Bash.

## 3. Preparación de la máquina virtual

Se utiliza la máquina **Server-IAW** de VirtualBox, con Ubuntu de 64 bits. El resto de máquinas de otras prácticas se mantienen apagadas para no consumir recursos.

![Captura 1](img/Captura%20de%20pantalla%202026-11-18%20101803.png)


La máquina tiene **4096 MB de RAM**, superior a los 2 GB mínimos que necesita PrestaShop.

![Captura 2](img/Captura%20de%20pantalla%202026-11-18%20095638.png)

### Configuración de red

El adaptador de red se configura en **modo puente (Adaptador puente)** para que la máquina obtenga una IP de la red local y se pueda acceder a ella desde el equipo anfitrión.

![Captura 3](img/Captura%20de%20pantalla%202026-11-18%20095658.png)

Con `ip a` se comprueba la IP de la máquina virtual: **192.168.100.94**.

![Captura 4](img/Captura%20de%20pantalla%202026-11-18%20095920.png)

Desde el equipo anfitrión se comprueba la conectividad con `ping`.

![Captura 4](img/Captura%20de%20pantalla%202026-11-18%20102016.png)

## 4. Descarga del repositorio  /por aqui voy/

Se instala Git y se clona el repositorio en la máquina virtual.

```bash
sudo apt update && sudo apt install -y git
git clone https://github.com/miiriiam108/Instalar-Prestashop-en-una-instancia-AWS.git
cd Instalar-Prestashop-en-una-instancia-AWS/scripts
ls -la
```

![Clonado del repositorio y contenido de scripts](img/07-clone-ls.png)

## 5. Archivo de configuración `.env`

Todas las variables que usan los scripts están en `scripts/.env`:

| Variable | Descripción |
|---|---|
| `DOMAIN` | IP de la máquina virtual (`192.168.100.94`) |
| `PS_SSL` | `0` = HTTP, `1` = HTTPS |
| `PHP_MEMORY_LIMIT`, `PHP_MAX_INPUT_VARS`, `PHP_POST_MAX_SIZE`, `PHP_UPLOAD_MAX_FILESIZE` | Directivas de `php.ini` que pide PhpPsInfo |
| `DB_ROOT_PASSWORD`, `DB_NAME`, `DB_USER`, `DB_PASSWORD` | Base de datos de PrestaShop |
| `PS_VERSION`, `PS_LANGUAGE`, `PS_COUNTRY`, `PS_ADMIN_EMAIL`, `PS_ADMIN_PASSWORD`, `PS_DB_PREFIX` | Datos de la instalación de PrestaShop |
| `PMA_APP_PASSWORD` | Contraseña interna de phpMyAdmin |

Se edita con `nano .env`, poniendo en `DOMAIN` la IP de la máquina. Las contraseñas reales no se suben al repositorio.

![Archivo .env configurado](img/08-env.png)

## 6. Instalación de la pila LAMP (`install_lamp.sh`)

```bash
chmod +x *.sh
sudo ./install_lamp.sh
```

El script realiza lo siguiente:

1. Actualiza los paquetes e instala **Apache** y activa los módulos `rewrite` y `headers`.
2. Instala **MySQL** y establece la contraseña de `root`.
3. Instala **PHP** con las extensiones que requiere PrestaShop: `mysql`, `curl`, `gd`, `intl`, `mbstring`, `xml`, `zip`, `bcmath` e `imagick`.
4. Ajusta las directivas de `php.ini` según el `.env`.
5. Copia `conf/000-default.conf` con `AllowOverride All`, necesario para el `.htaccess` de PrestaShop.
6. Instala **phpMyAdmin** de forma desatendida.
7. Descarga **PhpPsInfo** en `/var/www/html/phppsinfo/`.

![Final de la ejecución de install_lamp.sh](img/09-install-lamp.png)

## 7. Comprobación de requisitos con PhpPsInfo

Se accede desde el navegador a `http://192.168.100.94/phppsinfo/phppsinfo.php` con las credenciales por defecto (`prestashop` / `prestashop`).

![PhpPsInfo: versiones y configuración de PHP](img/10-phppsinfo-1.png)

![PhpPsInfo: extensiones, directorios y módulos de Apache](img/11-phppsinfo-2.png)

Una vez comprobado, este directorio debe eliminarse por seguridad.

## 8. phpMyAdmin

Se accede en `http://192.168.100.94/phpmyadmin`.

![phpMyAdmin](img/12-phpmyadmin.png)

## 9. Instalación de PrestaShop (`deploy_prestashop.sh`)

```bash
sudo ./deploy_prestashop.sh
```

El script realiza lo siguiente:

1. Crea la base de datos y el usuario de PrestaShop con los datos del `.env`.
2. Descarga de GitHub la versión indicada en `PS_VERSION` y la descomprime.
3. Copia los archivos a `/var/www/html` y asigna el propietario `www-data`.
4. Ejecuta el instalador por línea de comandos (`install/index_cli.php`) con el dominio, la base de datos, el correo y la contraseña del administrador.
5. Elimina el directorio `install` y reinicia Apache.

![Final de la ejecución de deploy_prestashop.sh](img/13-deploy.png)

## 10. Resultado

Tienda funcionando en `http://192.168.100.94`:

![Tienda PrestaShop](img/14-tienda.png)

Panel de administración (back office):

![Back office](img/15-backoffice.png)

## 11. HTTPS (opcional)

Como la máquina no tiene dominio público, no se puede usar Let's Encrypt. El script `setup_selfsigned_https.sh` genera un certificado autofirmado y activa el sitio SSL de Apache. Para usarlo se ejecuta antes del despliegue y se pone `PS_SSL=1` en el `.env`. El navegador mostrará un aviso de seguridad, que es normal con este tipo de certificado.

## 12. Referencias

- [Requisitos de PrestaShop](https://devdocs.prestashop-project.org/8/basics/installation/system-requirements/)
- [Instalación de PrestaShop desde CLI](https://devdocs.prestashop-project.org/8/basics/installation/install-from-cli/)
- [Código fuente de PrestaShop](https://github.com/PrestaShop/PrestaShop/tags)
- [PhpPsInfo](https://github.com/PrestaShop/php-ps-info)
