# Implantación de PrestaShop

## 1. Introducción

En esta práctica se instala la aplicación web **PrestaShop** sobre una pila LAMP, automatizando todo el proceso con scripts de Bash.

## 2. Preparación de la máquina virtual

Se utiliza la máquina **Server-IAW** de VirtualBox, con Ubuntu de 64 bits. El resto de máquinas de otras prácticas se mantienen apagadas para no consumir recursos.

![Captura 1](img/Captura%20de%20pantalla%202026-11-18%20101803.png)


La máquina tiene **4096 MB de RAM**, superior a los 2 GB mínimos que necesita PrestaShop.

![Captura 2](img/Captura%20de%20pantalla%202026-11-18%20095638.png)

### Configuración de red

El adaptador de red se configura en **modo puente (Adaptador puente)** para que la máquina obtenga una IP de la red local y se pueda acceder a ella desde el equipo anfitrión.

![Captura 3](img/Captura%20de%20pantalla%202026-11-18%20095658.png)

Con `ip a` se comprueba la IP de la máquina virtual: **192.168.1.11**.

![Captura 4](img/Captura%20de%20pantalla%202026-11-19%20203440.png)

Desde el equipo anfitrión se comprueba la conectividad con `ping`.

![Captura 5](img/Captura%20de%20pantalla%202026-11-19%20203606.png)

## 3. Instalación de la pila LAMP y comprobación de requisitos

Se ejecuta `install_lamp.sh` (con las variables configuradas en `.env`) para instalar Apache, MySQL, PHP y sus extensiones, ajustar `php.ini` y descargar `phppsinfo.php` en `/var/www/html/phppsinfo/`.

1. Accedemos desde el navegador a `http://192.168.1.11/phppsinfo/phppsinfo.php` e iniciamos sesión con las credenciales por defecto (`prestashop` / `prestashop`):

![Captura 6](img/Captura%20de%20pantalla%202026-11-19%20203011.png)

2. Comprobamos en las tablas de `phppsinfo` que los ajustes de PHP (`memory_limit = 256M`, `max_input_vars = 5000`, `post_max_size = 128M`, `upload_max_filesize = 128M`) y los requisitos necesarios aparecen en verde:

![Captura 7](img/Captura%20de%20pantalla%202026-11-19%20203027.png)

## 4. Despliegue de PrestaShop (Código fuente e instalación)

En este apartado se utiliza la última versión disponible de PrestaShop (**9.2.1**), obtenida desde el repositorio oficial de GitHub 

1. Configuro las variables de entorno en el archivo `.env` (`DOMAIN=192.168.1.11`, `PS_VERSION=9.2.1`, credenciales de base de datos y datos del administrador).

![Captura 8](img/Captura%20de%20pantalla%202026-11-20%20135440.png)

2. Ejecuto el script `deploy_prestashop.sh` para crear la base de datos `prestashop` y el usuario `ps_user` en MySQL, descomprimir el código fuente en `/var/www/html`, lanzar la instalación automatizada por línea de comandos (`index_cli.php`) y eliminar el directorio `install` por seguridad.
```bash
sudo ./deploy_prestashop.sh
```
![Captura 9](img/Captura%20de%20pantalla%202026-11-20%20135705.png)


## 5. Comprobación y resultado final

1. Accedo desde el navegador al **Front Office** a través de `http://192.168.1.11` para verificar que PrestaShop carga correctamente.

![Captura 10](ruta_a_tu_captura_10.png)

2. Accedo al **Back Office** (panel de administración) usando la ruta generada (`[http://192.168.1.11/admin](http://192.168.1.11/admin)...`) e inicio sesión con las credenciales configuradas en `.env`.

![Captura 11](ruta_a_tu_captura_11.png)


## 6. Comprobación de memoria RAM e IP de la máquina virtual
1. Arranco la máquina virtual en VirtualBox y abro la terminal de Ubuntu.
2. Ejecuto `free -h` y `ip -br a` para comprobar la RAM total asignada y la dirección IP activa en la red.

![Captura 10](img/Captura%20de%20pantalla%202026-11-20%20170516.png)

Como vemos tiene mas de 2GB de memoria.

## 7. Sistema operativo base equivalente a Ubuntu Server AMI
1. En lugar de seleccionar una Community AMI de Ubuntu Server en AWS EC2, se usa una máquina virtual (IP asignada `192.168.1.11/24` en `enp0s3`).
2. Compruebo la versión exacta de Ubuntu instalada ejecutando `cat /etc/os-release`

![Captura 11](img/Captura%20de%20pantalla%202026-11-20%20170843.png)

La salida muestra `PRETTY_NAME="Ubuntu 26.04.1 LTS"` (`VERSION_ID="26.04"`).

## 8. Configuración de puertos de red: SSH, HTTP y HTTPS (Tarea 3)
1. Como trabajo en una máquina virtual local con adaptador puente en lugar de un *Security Group* de AWS EC2, configuro los puertos directamente con `ufw` en Ubuntu.
2. Permito el tráfico entrante por TCP para `22/tcp` (SSH), `80/tcp` (HTTP) y `443/tcp` (HTTPS) y activo el cortafuegos.
3. Verifico el estado del cortafuegos y los sockets escuchando con `sudo ufw status verbose && ss -tulpn | grep -E ':22|:80|:443'`.

![Captura 12](img/Captura%20de%20pantalla%202026-11-20%20171449.png)

![Captura 13](img/Captura%20de%20pantalla%202026-11-20%20171753.png)


`Status: active` con las reglas `22/tcp`, `80/tcp` y `443/tcp` permitidas (`ALLOW IN`) y los servicios escuchando en el sistema.

## 9. Creación de par de claves SSH y conexión con la máquina virtual (Tarea 4)
1. Como trabajo en local con VirtualBox en lugar de generar un par de claves `.pem` en AWS EC2, creo la carpeta `.ssh` en mi equipo Windows y genero el par de claves SSH (privada `id_ed25519_prestashop` y pública `id_ed25519_prestashop.pub`):
   ```cmd
   mkdir "%USERPROFILE%\.ssh"
   ssh-keygen -t ed25519 -f "%USERPROFILE%\.ssh\id_ed25519_prestashop" -N ""

![Captura 14](img/Captura%20de%20pantalla%202026-11-20%20173625.png)

Envío la clave pública a la máquina virtual (miriam@192.168.1.11) para guardarla en ~/.ssh/authorized_keys y configuro los permisos necesarios (700 en ~/.ssh y 600 en authorized_keys):

![Captura 15](img/Captura%20de%20pantalla%202026-11-20%20173818.png)

Acepto la huella del host (yes) al conectar por primera vez y pruebo el acceso remoto usando mi clave privada:

![Captura 16](img/Captura%20de%20pantalla%202026-11-20%20173951.png)

inicio sesión directamente en la terminal de la máquina virtual (miriam@miriam:~$, sobre Ubuntu 26.04.1 LTS con IP 192.168.1.11) sin que me vuelva a pedir contraseña.

## 10. Dirección IP fija / equivalente a IP elástica en la máquina virtual (Tarea 5)
1. En AWS EC2 se asigna una *Elastic IP* para mantener una dirección IP pública constante; en mi entorno local con VirtualBox (Adaptador puente) utilizo el mismo enfoque para mantener la dirección **`192.168.1.11`** en la interfaz `enp0s3` (`08:00:27:c8:ad:d6`) de **Ubuntu 26.04.1 LTS**.
2. Reviso la configuración de red con `sudo ls -la /etc/netplan/` y `sudo cat /etc/netplan/*.yaml`, comprobando que el archivo `00-installer-config.yaml` pertenecía a `root` y tenía `dhcp4: true`.

![Captura 17](img/Captura%20de%20pantalla%202026-11-20%20174715.png)

3. Configuro la IP estática `192.168.1.11/24` en `/etc/netplan/00-installer-config.yaml`

![Captura 18](img/Captura%20de%20pantalla%202026-11-20%20175233.png)

la interfaz `enp0s3` mantiene `192.168.1.11/24` y la conexión SSH desde Windows sigue operativa sin cambiar de IP.


## 11. Registro de nombre de dominio gratuito 
1. Accedo a **No-IP** e inicio sesión en mi cuenta.

![Captura 19](img/Captura%20de%20pantalla%202026-11-20%20175906.png)

2.Creo el nombre de host `prestashop-miriam.bounceme.net` bajo la zona `bounceme.net` como registro de tipo `A` apuntando a `45.13.201.205` (TTL `60`).

![Captura 20](img/Captura%20de%20pantalla%202026-11-20%20180003.png)

3. Compruebo la resolución del nombre de dominio mediante `nslookup prestashop-miriam.bounceme.net`.

![Captura 21](img/Captura%20de%20pantalla%202026-11-20%20180831.png)

el registro aparece activo en No-IP (`prestashop-miriam.bounceme.net`, tipo `A`, contenido `45.13.201.205`) y resuelve correctamente por DNS.


## 12. Configuración de registros DNS hacia la dirección IP (Tarea 7)
1.En VirtualBox (Ubuntu 26.04.1 LTS en `192.168.1.11`), configuro el registro `A` de `prestashop-miriam.bounceme.net` en No-IP apuntando a `45.13.201.205`.
2. Compruebo la resolución del nombre de dominio desde la terminal mediante `nslookup prestashop-miriam.bounceme.net`.

![Captura 22](img/Captura%20de%20pantalla%202026-11-20%20180831.png)

`nslookup` devuelve `prestashop-miriam.bounceme.net` resolviendo hacia `45.13.201.205` a través del resolvedor `127.0.0.53`.

## 13. Instalación automatizada de LAMP y phpMyAdmin mediante script
1. Me conecto por SSH desde Windows a mi máquina virtual Ubuntu 26.04.1 LTS (`192.168.1.11`) y accedo a `~/Instalar-Prestashop-en-una-instancia-AWS/scripts` para preparar y ejecutar `install_lamp.sh` (`chmod +x install_lamp.sh` y `sudo ./install_lamp.sh`), automatizando la instalación de Apache, MySQL, PHP 8.5 con sus extensiones, los ajustes de `php.ini`, el *virtual host* (`000-default.conf`), **phpMyAdmin** y PhpPsInfo.
2. Durante el proceso resuelvo el aviso de autenticación de `root@localhost` en MySQL aplicando `caching_sha2_password` y completo las opciones interactivas de **phpMyAdmin** (`apache2` y `dbconfig-common`), así como los pasos finales de descarga de PhpPsInfo, permisos sobre `/var/www/html` y reinicio de Apache.
3. Compruebo el estado de los servicios con `systemctl status apache2 mysql --no-pager` y verifico el acceso web a **phpMyAdmin**, eliminando después `/var/www/html/phppsinfo` al terminar la comprobación.

![Captura 23](img/Captura%20de%20pantalla%202026-11-20%20190159.png)

![Captura 24](img/Captura%20de%20pantalla%202026-11-20%20185847.png)

`apache2.service` y `mysql.service` quedan en estado `active (running)` y phpMyAdmin responde correctamente en el navegador.


## 14. Instalación de Certbot y configuración SSL/TLS

1. Instalo y compruebo `certbot` y `python3-certbot-apache`, verificando que el temporizador `certbot.timer` está activo (`certbot --version` y `sudo systemctl status certbot.timer --no-pager`).


![Captura 25](img/Captura%20de%20pantalla%202026-11-21%20182032.png)

2. Solicito el certificado de Let's Encrypt para `prestashop-miriam.bounceme.net` mediante validación HTTP-01 (`sudo certbot --apache -d prestashop-miriam.bounceme.net`), obteniendo *timeout* en el puerto `80` hacia `45.13.201.205`, mientras compruebo que Apache responde en local (`curl -I http://192.168.1.11` -> `HTTP/1.1 200 OK`).


![Captura 26](img/Captura%20de%20pantalla%202026-11-21%20182140.png)

3. Pruebo el reto alternativo DNS-01 (`sudo certbot certonly --manual --preferred-challenges dns -d prestashop-miriam.bounceme.net`) y compruebo con `dig @8.8.8.8 +short TXT _acme-challenge.prestashop-miriam.bounceme.net` que no aparece el registro `TXT` por las limitaciones del subdominio gratuito `*.bounceme.net` en No-IP.


![Captura 27](img/Captura%20de%20pantalla%202026-11-21%20182555.png)

4. Para activar HTTPS (`443`) en el entorno de pruebas, ejecuto `sudo ./setup_letsencrypt_https.sh` y verifico la conexión segura y el certificado generado con `curl -kI https://192.168.1.11` y `openssl x509 -in /etc/ssl/certs/prestashop.crt -noout -subject -dates`.

![Captura 28](img/Captura%20de%20pantalla%202026-11-21%20182833.png)

![Captura 29](img/Captura%20de%20pantalla%202026-11-21%20182843.png)













