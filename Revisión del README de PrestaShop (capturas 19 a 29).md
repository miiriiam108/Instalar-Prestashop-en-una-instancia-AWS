# Revisión del README de PrestaShop (capturas 19 a 29)

Revisión de las capturas de los apartados 11 a 14 frente al texto del README. Casi todo coincide con lo que escribes, pero hay una imagen que se va a romper y una explicación del certificado que conviene corregir.

## Lo que hay que arreglar

### 1. Una imagen del apartado 14 va a salir rota

En el README la Captura 27 apunta a `...2026-11-21%20182555.png`, pero tu archivo se llama `...2026-11-21_182255.png` (con 22, no con 25). Comprueba cómo se llama en tu carpeta `img` y corrige la ruta.

### 2. El certificado es autofirmado, no de Let's Encrypt

Las capturas 28 y 29 lo demuestran: el script ejecuta `openssl req -x509 ...` y el certificado tiene `O=Practica, CN=192.168.1.11`, no el dominio. Tu apartado 14 lo cuenta de forma ambigua, y el script se llama `setup_letsencrypt_https.sh`. Escribe claramente que, como Let's Encrypt no pudo validar, usaste un certificado autofirmado de prueba.

Para conseguir el certificado real, lo más probable es que haga falta esto:

- Redirigir en tu router los puertos TCP 80 y 443 a `192.168.1.11`.
- Comprobar que la IP pública de tu router es de verdad `45.13.201.205`. Si es otra, tu operadora usa CGNAT y no hay forma de abrir puertos. En ese caso explícalo en el README.
- Abrir el 443 en el cortafuegos con `sudo ufw allow 443/tcp`. Sigue faltando, como vimos en las capturas 12 y 13. El `curl` de la Captura 29 funciona porque lo lanzas desde la propia máquina, pero desde Windows el HTTPS estaría bloqueado.
- Repetir `sudo certbot --apache -d prestashop-miriam.bounceme.net`.

### 3. La Captura 27 no demuestra lo que dices

Dices que el `dig` confirma que no aparece el registro TXT, pero la captura termina justo al escribir el comando, sin ver su salida. Repite la captura incluyendo el resultado. También conviene suavizar "por las limitaciones del subdominio gratuito" si no lo has comprobado en la documentación de No-IP, por ejemplo con "no pude crear el registro TXT en mi cuenta gratuita".

### 4. Datos privados a la vista

La Captura 28 imprime todo el `.env` por el `set -x` del script: contraseñas (`8888`) y tu correo del instituto. La Captura 19 también muestra tu correo arriba a la derecha. Si el repositorio es público, tápalos o repite la captura.

## Apartados 11 y 12

- Tienes una captura sin usar, `...180722.png`, que muestra el registro de No-IP activo (tipo A, `45.13.201.205`, TTL 60). Es la que respalda la frase "el registro aparece activo". Ponla en el apartado 11 en lugar de repetir el `nslookup`, y deja el `nslookup` para el 12.
- En la Captura 20 el TTL sale como "Automático" y el README dice `60`. Se resuelve al ver el registro final, pero no es la misma pantalla.
- No-IP pide confirmar los nombres de host gratuitos cada 30 días (sale en la Captura 19). Confírmalo antes de la corrección para que no caduque.

## Lo que coincide

- Captura 23: `apache2` y `mysql` en `active (running)`.
- Captura 24: login de phpMyAdmin.
- Captura 25: `certbot 4.0.0` con el timer activo.
- Captura 26: timeout del reto HTTP-01 más `curl` con `200 OK`.
- El `nslookup` hacia `45.13.201.205` y la creación del registro A en No-IP son correctos.

## Siguiente paso

Si quieres, te devuelvo el README completo con todos los cambios de redacción de las dos revisiones (numeración, apartado 14, apartados 11 y 12, y los textos de las capturas), dejando marcados con un comentario los sitios donde tú tienes que repetir una captura.
