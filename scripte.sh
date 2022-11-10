echo " Actualizamos repositorios y paquetes"

    sudo apt update 
    sudo apt upgrade -y

echo "Instalacion de paquetes LEMP. nginx"
    sudo apt -y install nginx 
    sudo systemctl reload nginx
    sudo apt -y install default-mysql-client
    sudo apt -y install php-mysql

echo " Instalacion de php"
    sudo apt -y install php-fpm

    #sudo apt -y install phpmyadmin php-mbstring php-zip php-gd php-json php-curl
    #instalamos adminer y lo movemos al www
 sudo wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-mysql.php
 sudo find / -type f -name *adminer* -exec mv {} /var/www/adminer.php \; 




echo "Instalamos git"

    sudo apt -y install git



