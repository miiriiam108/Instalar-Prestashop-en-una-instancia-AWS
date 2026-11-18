#!/bin/bash
# Solicita un certificado de Let's Encrypt con Certbot y lo configura en Apache
set -ex

source "$(dirname "$0")/.env"

snap install core
snap refresh core
apt remove -y certbot || true
snap install --classic certbot
ln -sf /snap/bin/certbot /usr/bin/certbot

certbot --apache \
  -m "$LE_EMAIL" \
  --agree-tos \
  --no-eff-email \
  -d "$DOMAIN" \
  --non-interactive \
  --redirect
