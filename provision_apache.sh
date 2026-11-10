#!/bin/bash
# Aprovisionamiento de la máquina web (AdrianRiosApache)

# Muestra cada orden por pantalla y para si alguna falla
set -ex

# ----- Variables (deben coincidir con provision_mysql.sh) -----
DB_HOST=192.168.56.11
DB_NAME=lamp_db
DB_USER=lamp_user
DB_PASSWORD=lamp_password

# 1. Actualizar la lista de paquetes
apt-get update

# 2. Instalar Apache, PHP, el conector de PHP con MySQL y git
apt-get install -y apache2 php libapache2-mod-php php-mysql git

# 3. Descargar la aplicación de GitHub
rm -rf /tmp/iaw-practica-lamp
git clone https://github.com/josejuansanchez/iaw-practica-lamp.git /tmp/iaw-practica-lamp

# 4. Borrar la página por defecto de Apache y copiar la aplicación
rm -f /var/www/html/index.html
cp -r /tmp/iaw-practica-lamp/src/* /var/www/html/

# 5. Ajustar config.php con los datos de la base de datos
sed -i "s/localhost/$DB_HOST/"              /var/www/html/config.php
sed -i "s/database_name_here/$DB_NAME/"     /var/www/html/config.php
sed -i "s/username_here/$DB_USER/"          /var/www/html/config.php
sed -i "s/password_here/$DB_PASSWORD/"      /var/www/html/config.php

# 6. Dar los ficheros al usuario de Apache
chown -R www-data:www-data /var/www/html

# 7. Reiniciar Apache para aplicar los cambios
systemctl restart apache2
