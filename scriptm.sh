echo " Actualizamos paquetes"

    sudo apt update
    sudo apt upgrade -y

echo "Instalacion de mysql"
    sudo apt -y install default-mysql-server
    

echo "Modificamos password de root"

#tambien podemos usar el secure instalation y ahi nos permite elegir la contraseña
sudo mysql -u root <<EOF
alter user 'root'@'localhost' identified by '1234'
EOF


#creamos el usuario dentro con CREATE USER 'abel'@'192.168.21.21' IDENTIFIED BY '11111111';"
# le damos todos los permisos a este user en la ip del nginx con grant all privileges
#sudo mysql -u root -e "FLUSH PRIVILEGES;"
sudo systemctl reload mysql-server

#sudo ip route del default
#sudo ip route add default via 172.16.10.1