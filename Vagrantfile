# -*- mode: ruby -*-
# vi: set ft=ruby :

# Pila LAMP en dos niveles
#   - AdrianRiosMysql  -> servidor de base de datos (SIN Internet)
#   - AdrianRiosApache -> servidor web Apache + PHP (CON Internet por NAT)

Vagrant.configure("2") do |config|

  # Box de Debian 12 (Bookworm) para las dos máquinas
  config.vm.box = "debian/bookworm64"

  # ---------- MÁQUINA 1: BASE DE DATOS ----------
  # Se define primero para que arranque antes que Apache
  config.vm.define "mysql" do |mysql|
    mysql.vm.hostname = "AdrianRiosMysql"

    # Red privada: solo se comunica con la máquina Apache
    mysql.vm.network "private_network", ip: "192.168.56.11"

    mysql.vm.provider "virtualbox" do |vb|
      vb.name   = "AdrianRiosMysql"
      vb.memory = 1024
    end

    # Aprovisionamiento: instala MariaDB y crea la base de datos
    mysql.vm.provision "shell", path: "provision_mysql.sh"

    # Cada vez que arranca, se borra la ruta por defecto
    # para que la máquina NO tenga salida a Internet
    mysql.vm.provision "shell", run: "always",
      inline: "ip route del default 2>/dev/null || true"
  end

  # ---------- MÁQUINA 2: SERVIDOR WEB ----------
  config.vm.define "apache" do |apache|
    apache.vm.hostname = "AdrianRiosApache"

    # Red privada para hablar con la base de datos
    apache.vm.network "private_network", ip: "192.168.56.10"

    # Reenvío de puertos: localhost:8080 (tu PC) -> puerto 80 (Apache)
    apache.vm.network "forwarded_port", guest: 80, host: 8080

    apache.vm.provider "virtualbox" do |vb|
      vb.name   = "AdrianRiosApache"
      vb.memory = 1024
    end

    # Aprovisionamiento: instala Apache + PHP y despliega la aplicación
    apache.vm.provision "shell", path: "provision_apache.sh"
  end

end
