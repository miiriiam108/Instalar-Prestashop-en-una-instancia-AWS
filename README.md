# Práctica 1.8 - Implantación de PrestaShop en una máquina virtual

## 1. Máquina virtual
- Hipervisor: VirtualBox / VMware (indica cuál).
- Ubuntu Server (última versión), 2 GB de RAM mínimo, 20 GB de disco.
- Red: adaptador en modo **puente (bridge)** para que el equipo anfitrión acceda a la VM.
- Servidor SSH instalado (`sudo apt install openssh-server`).

> Añade capturas de la configuración de la VM.

## 2. Instalación
```bash
git clone <URL_DEL_REPO> && cd <REPO>/scripts
nano .env                      # pon la IP de la VM y las contraseñas
sudo ./install_lamp.sh
# Comprueba requisitos en http://IP_VM/phppsinfo/phppsinfo.php (prestashop / prestashop)
sudo ./deploy_prestashop.sh
# Opcional: sudo ./setup_selfsigned_https.sh  (y PS_SSL=1 en .env antes del deploy)
```

## 3. Scripts
- `.env`: variables de configuración.
- `install_lamp.sh`: Apache, MySQL, PHP + extensiones, php.ini, phpMyAdmin y PhpPsInfo.
- `deploy_prestashop.sh`: base de datos, descarga e instalación por CLI en `/var/www/html`.
- `setup_selfsigned_https.sh`: (opcional) HTTPS con certificado autofirmado.

## 4. Resultado
> Capturas de la tienda y del back office.
