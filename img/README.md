# Implantación de PrestaShop en AWS

## 1. Infraestructura en AWS
1. Instancia EC2 (≥ 2 GB RAM, p. ej. t3.small) con la última Ubuntu Server (Community AMI).
2. Security Group: SSH (22), HTTP (80), HTTPS (443).
3. Par de claves para SSH.
4. IP elástica asociada a la instancia.
5. Dominio gratuito (No-IP, etc.) con registro A hacia la IP elástica.

> Añade aquí capturas de pantalla de cada paso.

## 2. Instalación
```bash
git clone <URL_DEL_REPO> && cd <REPO>/scripts
nano .env                      # configura dominio, correo y contraseñas
sudo ./install_lamp.sh
# Comprueba requisitos en https://TU_DOMINIO/phppsinfo/phppsinfo.php
sudo ./setup_letsencrypt_https.sh
sudo ./deploy_prestashop.sh
```

## 3. Descripción de los scripts
- `.env`: variables de configuración.
- `install_lamp.sh`: Apache, MySQL, PHP + extensiones, ajustes de php.ini, phpMyAdmin y PhpPsInfo.
- `setup_letsencrypt_https.sh`: Certbot y certificado de Let's Encrypt.
- `deploy_prestashop.sh`: base de datos, descarga e instalación por CLI en `/var/www/html`.

## 4. Resultado
> Capturas de la tienda y del back office.
