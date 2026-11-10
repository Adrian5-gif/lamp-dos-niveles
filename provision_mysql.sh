#!/bin/bash
# Aprovisionamiento de la máquina de base de datos (AdrianRiosMysql)

# Muestra cada orden por pantalla y para si alguna falla
set -ex

# ----- Variables -----
DB_NAME=lamp_db
DB_USER=lamp_user
DB_PASSWORD=lamp_password
APACHE_IP=192.168.56.10

# 1. Actualizar la lista de paquetes
apt-get update

# 2. Instalar MariaDB (en Debian 12 sustituye a MySQL)
apt-get install -y mariadb-server

# 3. Permitir conexiones desde otras máquinas
#    Por defecto MariaDB solo escucha en 127.0.0.1
sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

# 4. Reiniciar MariaDB para aplicar el cambio
systemctl restart mariadb

# 5. Crear la base de datos y la tabla de la aplicación
mysql -u root <<EOF
DROP DATABASE IF EXISTS $DB_NAME;
CREATE DATABASE $DB_NAME CHARSET utf8mb4;
USE $DB_NAME;

CREATE TABLE users (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  age INT UNSIGNED NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
EOF

# 6. Crear el usuario que usará la aplicación
#    Solo puede conectarse desde la IP de la máquina Apache
mysql -u root <<EOF
DROP USER IF EXISTS '$DB_USER'@'$APACHE_IP';
CREATE USER '$DB_USER'@'$APACHE_IP' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'$APACHE_IP';
FLUSH PRIVILEGES;
EOF

# 7. Quitar la puerta de enlace para que la máquina NO tenga Internet
#    (el Vagrantfile lo repite en cada arranque)
ip route del default || true
