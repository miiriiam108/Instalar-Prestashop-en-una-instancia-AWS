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

En este apartado se utiliza la última versión disponible de PrestaShop (**9.2.1**), obtenida desde el repositorio oficial de GitHub (`[https://github.com/PrestaShop/PrestaShop/tags](https://github.com/PrestaShop/PrestaShop/tags)`).

1. Configuramos las variables de entorno en el archivo `.env` (`DOMAIN=192.168.1.11`, `PS_VERSION=9.2.1`, credenciales de base de datos y datos del administrador)[cite: 5].

![Captura 8](img/Captura%20de%20pantalla%202026-11-20%20135440.png)

2. Ejecutamos el script `deploy_prestashop.sh` para crear la base de datos `prestashop` y el usuario `ps_user` en MySQL, descomprimir el código fuente en `/var/www/html`, lanzar la instalación automatizada por línea de comandos (`index_cli.php`) y eliminar el directorio `install` por seguridad[cite: 6].

```bash
sudo ./deploy_prestashop.sh
```
![Captura 9](img/Captura%20de%20pantalla%202026-11-20%20135705.png)


## 5. Comprobación y resultado final

1. Accedemos desde el navegador al **Front Office** (tienda pública) a través de `http://192.168.1.11` para verificar que PrestaShop carga correctamente[cite: 5].

![Captura 10](ruta_a_tu_captura_10.png)

2. Accedemos al **Back Office** (panel de administración) usando la ruta generada (`[http://192.168.1.11/admin](http://192.168.1.11/admin)...`) e iniciamos sesión con las credenciales configuradas en `.env`[cite: 5, 6].

![Captura 11](ruta_a_tu_captura_11.png)
