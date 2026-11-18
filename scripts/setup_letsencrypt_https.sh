#!/bin/bash
# OPCIONAL: HTTPS con certificado autofirmado (el navegador mostrará un aviso)
set -ex
source "$(dirname "$0")/.env"

a2enmod ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/prestashop.key \
  -out /etc/ssl/certs/prestashop.crt \
  -subj "/C=ES/ST=Extremadura/L=Merida/O=Practica/CN=${DOMAIN}"

sed -i 's#/etc/ssl/certs/ssl-cert-snakeoil.pem#/etc/ssl/certs/prestashop.crt#; s#/etc/ssl/private/ssl-cert-snakeoil.key#/etc/ssl/private/prestashop.key#' \
  /etc/apache2/sites-available/default-ssl.conf
a2ensite default-ssl
systemctl restart apache2
