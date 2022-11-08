# Practica lamp en dos capas
En esta practica separaremos servidor de apache y mysql para dar mayor seguridad y control sobre nuestro entorno de trabajo.

## Primer paso: Vagrant
Generamos un archivo vagrant con vagrant init
Vamos a explicar las lineas que modificamos o añadimos según las necesidades del proyecto


    config.vm.define "serverapache" do |serverapache|

    serverapache.vm.box = "debian/bullseye64"

    serverapache.vm.hostname = "AbelMonApache"

    serverapache.vm.network "public_network"

    serverapache.vm.network "private_network", ip: "192.168.21.21"

    serverapache.vm.synced_folder "./","/vagrant"

    serverapache.vm.provision "shell", path: "scripta.sh"


* Vamos a definir el servidor como "serverapache". 

* Utilizaremos una debian bullseye.
* Le asignamos el nombre al servidor que nos requiere la practica. 
* En este servidor añadimos interfaz pública y privada, ya que requiere salida a exterior y tambien conectarse al equipo MYSQL en red local. Este utimo servidor solo tendrá la red privada, por tanto un único adaptador de red, con una ip local 192.168.21.22 /24 .
* En ambos casos definimos como la carpeta compartida la ruta /vagrant
Para dar un entorno listo para comenzar a configurar aprovisionaremos con dos scripts que previamente hemos hecho para ambas maquinas, al estar en la ruta del vagrant con poner el nombre en el path es suficiente.


## Scripts de aprovisionamiento
### Script script apache

```
echo " Actualizamos repositorios y paquetes"

    sudo apt update 
    sudo apt upgrade -y

echo "Instalacion de paquetes LAMP. Apache"
    sudo apt -y install apache2 
    sudo systemctl reload apache2
    sudo apt -y install default-mysql-client

echo " Instalacion de php"
    sudo apt -y install php libapache2-mod-php php-mysql

    #sudo apt -y install phpmyadmin php-mbstring php-zip php-gd php-json php-curl
    #instalamos adminer y lo movemos al directorio www
 sudo wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-mysql.php
 sudo find / -type f -name *adminer* -exec mv {} /var/www/adminer.php \; 

echo "Instalamos git"
sudo apt -y install git
```

* En este script vamos a actualizar repositorios y paquetes con update y upgrade.
* Instalaremos apache mostrando algunos mensajes al usuario.
* Instalamos tambien mysql para conectarnos al servidor
* Una vez instalado el codigo sigue instalando PHP
* En este caso no instalamos phpmyadmin, por eso comentamos con#. No conseguimos que funcione, y nos paraliza la instalacion.
* Para subsanarlo instalamos adminer que ademas es más ligero y sencillo de implementar. Una vez descargado buscamos su ubicación y la movemos al directorio /www, para tenerlo localizado facilmente a la hora de moverlo al directorio final de nuestra aplicación.
* El último paso es instalar git para cualquier necesidad de actualizar nuestro proyecto.

### Script servidor Mysql

```
echo " Actualizamos paquetes"

    sudo apt update
    sudo apt upgrade -y

echo "Instalacion de mysql"
    sudo apt -y install default-mysql-server
    

# Definimos variables para la creacion de usuario mysql
        usuariodb="abel"
        passdb="11111111"
############################

echo "Crear usuario para MYSQL y modificar password de root"

#creamos el usuario que definimos en variable para el cliente .21.21
sudo mysql -u root -e "CREATE USER '$usuariodb'@'192.168.21.21' IDENTIFIED BY '$passdb';"
# damos todos los privilegios al usuario desde la ip del cliente
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '$usuariodb'@'192.168.21.21';"
# modificamos root del servidor para ponerle la pass 1234
sudo mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '1234';"
# Actualizamos privilegios
sudo mysql -u root -e "FLUSH PRIVILEGES;"
# Finalmente recargamos el servidor mysql para que adopte la nueva configuración
sudo systemctl reload mysql-server
```
Comentaremos brevemente, ya que todas las lineas del script estan comentadas.

* Actualización de paquetes y repositorios
* Instalamos la version de mysql actual, que previamente buscamos con apt search
* Vamos a crear unas variables para definir usuario y contraseña del usuario administrador, que podriamos darle mayor utilidad en otro contexto.
* Creamos el usuario, con la contraseña que generamos y le damos todos los permisos en todo el servidor.
* Cambiamos la contraseña de root, y recargamos la configuración.

## Conectividad entre máquinas

Una vez comprobado que se instala todo sin problemas, vamos a realizar un ping entre ambos equipos.
``` Ping 192.168.21.22 ```
Al ejecutar desde apache (192.168.21.21) nos da respuesta.

Para mostrarle al servidor Mysql cual es la ip donde tiene que permitir conexiones buscaremos el archivo "50-server.cnf" para cambiar este parametro por la ip del servidor mysql. 
La ruta sera la siguiente:
```
/etc/mysql/mariadb.conf.d/50-server.cnf
```
El parametro a modificar por la ip de nuestro servidor
```bind-address            = 192.168.21.22```

Una vez hecho, comprobamos que podemos conectarnos con el usuario creado desde apache.
```
mysql -u abel -p -h 192.168.21.22
```
Todo correcto, es hora de implementar nuestra aplicación.

## Implementación de aplicación

Clonamos con git clone desde el repositorio proporcionado.
```git clone https://github.com/josejuansanchez/iaw-practica-lamp.git```
#### Pasos para la aplicación
1. Descargamos los archivos en a ruta compartida con vagrant.
2. Movemos los archivos de la aplicacíon a una nueva carpeta creada en /www/var/.
En nuestra prática sera /www/var/app.
3. Movemos el adminer.php a esta misma ruta.
4. Una vez que tenemos todos los archivos, modificamos el archivo 000-default situado en sites-enabled para decirle que la ruta nueva sera /www/var/app y no /html.
5. Modificamos el dueño de los archivos para darselos a apache estando en la ruta de los archivos. ```sudo chown www-data.www-data *```
6. Configuramos el archivo config.php para indicarle los parametros de nuestro usuario y base de datos que tiene que utilizar en la ejecución de la aplicación.
7. Reiniciamos apache
```sudo systemctl restart apache```

#### Configuración de la base de datos
1. En primer lugar modificaremos el archivo database.sql para adecuarlo al usuario y contraseña que generamos para nuestro cliente. 
2. Una vez modificado entramos en el gestor con ```mysql -u abel -p -h 192.168.21.22```
3. Le decimos la ruta de donde tiene que importar la base de datos
```source /vagrant/db/database.sql```
4. Comprobamos que podemos hacer consultas, y que nos arroja los datos que previamente insertamos desde un navegador web.


### Capturas de interconexión de máquinas

#### Podemos ver el nombre de las diferentes maquinas y como ambas se pueden conectar, una desde remoto con el usuario abel y otra desde root en local.


![](imagenes/apache.PNG)
![](imagenes/mysql.PNG)
