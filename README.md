# práctica LEMP en dos capas con balanceador
En esta práctica separaremos servidor de nginx, mysql y balanceador para dar mayor seguridad y control sobre nuestro entorno de trabajo, poder administrar mejor los picos de trabajo dirigiendo la carga a cualquiera de los dos servidores nginx que tendrán replicado el sitio que implementaremos.

## Primer paso: Vagrant
Generamos un archivo vagrant con vagrant init
Vamos a explicar las líneas que modificamos o añadimos según las necesidades del proyecto


    config.vm.define "servernginx" do |servernginx|

    servernginx.vm.box = "debian/bullseye64"

    servernginx.vm.hostname = "AbelMonNginx"

    servernginx.vm.network "public_network"

    servernginx.vm.network "private_network", ip: "192.168.21.21"

    servernginx.vm.synced_folder "./","/vagrant"

    servernginx.vm.provision "shell", path: "scripte.sh"


* Vamos a definir el servidor como "servernginx". 

* Utilizaremos una debian bullseye.
* Le asignamos el nombre al servidor que nos requiere la práctica. 
* En este servidor añadimos interfaz pública y privada, ya que requiere salida a exterior y también conectarse al equipo MYSQL en red local. Este último servidor solo tendrá la red privada, por tanto, un único adaptador de red, con una ip local 192.168.21.22 /24 .
* En ambos casos definimos como la carpeta compartida la ruta /vagrant
Para dar un entorno listo para comenzar a configurar aprovisionaremos con dos scripts que previamente hemos hecho para ambas máquinas, al estar en la ruta del vagrant con poner el nombre en el path es suficiente.


## Scripts de aprovisionamiento
### Script nginx

```
echo " Actualizamos repositorios y paquetes"

    sudo apt update 
    sudo apt upgrade -y

echo "Instalación de paquetes lemp. Nginx , mysql y php"
    sudo apt -y install nginx 
    sudo systemctl reload nginx
    sudo apt -y install default-mysql-client
    sudo apt -y install php-mysql
    sudo apt -y install php-fpm

    #sudo apt -y install phpmyadmin php-mbstring php-zip php-gd php-json php-curl
    #instalamos adminer y lo movemos al directorio www
 sudo wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-mysql.php
 sudo find / -type f -name *adminer* -exec mv {} /var/www/adminer.php \; 

echo "Instalamos git"
sudo apt -y install git
```

* En este script vamos a actualizar repositorios y paquetes con update y upgrade.
* Instalaremos nginx mostrando algunos mensajes al usuario.
* Instalamos también mysql para conectarnos al servidor
* Una vez instalado sigue instalando PHP
* En este caso no instalamos phpmyadmin, por eso comentamos con#.
* Instalamos adminer que además es más ligero y sencillo de implementar. Una vez descargado buscamos su ubicación y la movemos al directorio /www, para tenerlo localizado fácilmente a la hora de moverlo al directorio final de nuestra aplicación.
* El último paso es instalar git para actualizar nuestro proyecto.

### Script servidor Mysql

```
echo " Actualizamos paquetes"

    sudo apt update
    sudo apt upgrade -y

echo "Instalación de mysql"
    sudo apt -y install default-mysql-server
    
echo "Modificar password de root"

sudo mysql -u root <<EOF
alter user 'root'@'localhost' identified by '1234'
EOF

El usuario lo crearemos más tarde entrando con root, dándole acceso a los dos servidores nginx por su ip.

# Actualizamos privilegios
sudo mysql -u root -e "FLUSH PRIVILEGES;"
# Finalmente recargamos el servidor mysql para que adopte la nueva configuración
sudo systemctl reload mysql-server
```
Comentaremos brevemente, ya que todas las líneas del script están comentadas.

* Actualización de paquetes y repositorios
* Instalamos la versión de mysql actual, que previamente buscamos con apt search
* Una vez modificada la password de root en el aprovisionamiento, creamos el usuario con la contraseña que generamos y le damos todos los permisos en todo el servidor.


## Conectividad entre máquinas

Una vez comprobado que se instala todo sin problemas, vamos a realizar un ping entre ambos equipos.
``` Ping 192.168.21.22 ```
Al ejecutar desde nginx y desde nginx2 (192.168.21.21-30) nos da respuesta.

Para mostrarle al servidor Mysql cual es la ip donde tiene que permitir conexiones buscaremos el archivo "50-server.cnf" para cambiar este parámetro por la ip del servidor mysql. 
La ruta será la siguiente:
```
/etc/mysql/mariadb.conf.d/50-server.cnf
```
El parámetro a modificar por la ip de nuestro servidor mysql/mariaDb
```bind-address            = 192.168.21.22```

Una vez hecho, comprobamos que podemos conectarnos al servidor mysql con el usuario creado, desde el servidor nginx y desde el servidor replicado nginx2.
```
mysql -u abel -p -h 192.168.21.22
```
Todo correcto, es hora de implementar nuestra aplicación.

## Implementación de aplicación

Clonamos con git clone desde el repositorio proporcionado.
```git clone https://github.com/josejuansanchez/iaw-práctica-lamp.git```
#### Pasos para la aplicación
1. Descargamos los archivos con git, los alojaremos en el home.
2. Movemos los archivos de la aplicación a una nueva carpeta creada en /www/var/.
En nuestra práctica será /www/var/apli.
3. Movemos el adminer.php a esta misma ruta.
4. Una vez que tenemos todos los archivos, podemos copiar o editar el archivo default situado en sites-available o en sites-enabled ya que son el mismo archivo, lo modificamos para decirle que la ruta nueva será /www/var/apli y no /html, ya que al no tener más sitios no tenemos necesidad de crear otro nuevo y crear el enlace.
5. Tenemos que des comentar las líneas de php para que nos admita estos archivos.
 En nuestro caso utilizaremos un socket local para la interconexión entre nginx y php, ya que estará en la misma máquina y más rápido que el TCP/IP. Hay que comprobar que la versión que tenemos es la 7.4, ya que podría variar.
```location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                fastcgi_pass unix:/run/php/php7.4-fpm.sock;
        }```
6. También vamos añadir el index.php a la lista de index que permite nginx.
La pondremos la primera para darle prioridad y que nos muestre el index.php si existe.
```# Add index.php to the list if you are using PHP
        index index.php index.html index.htm index.nginx-debian.html;```
7. Modificamos el dueño de los archivos para dárselos a nginx estando en la ruta de los archivos. ```sudo chown -R www-data.www-data *```
8. Configuramos el archivo config.php para indicarle los parámetros de nuestro usuario y base de datos que tiene que utilizar en la ejecución de la aplicación. Los definimos como abel y 11111111.
9. Reiniciamos nginx
```sudo systemctl restart nginx```

#### Configuración de la base de datos
1. Nos conectamos al servidor MYSQL con root y la contraseña que definimos en el aprovisionamiento. Una vez dentro creamos un usuario para dar acceso a nginx. En este caso habría que hacerlo para los dos servidores nginx, por tanto, las dos ips .21 y .30. Aunque sea el mismo usuario, debemos darle acceso desde ambas ips.
```CREATE USER 'abel'@'192.168.21.21' IDENTIFIED BY '11111111';```
2. Le damos todos los privilegios al usuario y actualizamos privilegios .
```GRANT ALL PRIVILEGES ON *.* TO 'abel'@'192.168.21.21'`;```
```FLUSH PRIVILEGES;```
3. Una vez creado el usuario, modificaremos el archivo database.sql para adecuarlo al usuario y contraseña que generamos para nuestro cliente. 
4. Entramos en el servidor mysql desde nginx con ```mysql -u abel -p -h 192.168.21.22```
5. Le decimos la ruta de donde tiene que importar la base de datos
```source /home/vagrant/db/database.sql```
6. Comprobamos que podemos hacer consultas, y que nos arroja los datos que previamente insertamos desde un navegador web.

``````
### Capturas de interconexión de máquinas

#### Podemos ver el nombre de las diferentes máquinas y como ambas se pueden conectar con el usuario abel desde los diferentes servidores nginx.


![](imagenes/ngin.PNG))
![](imagenes/nginx.PNG)

## Creación de balanceador de carga

La configuración del servidor que actuara como balanceador, será nuestro frontal, por tanto, el único servidor visible de cara al usuario final. Para acceder a nuestros sitios web de nginx lo harán a través de esta ip.
La configuración es sencilla, solo debemos configurar el archivo default de sites-available e implementar las siguientes líneas, o bien borrarlo y crear uno nuevo con este contenido:

```      
upstream backend {

 server 192.168.10.10;
 server 192.168.10.11;
}

server {


        location / {
        proxy_pass http://backend;
        }
}
```

### Contenido del archivo y algoritmo 

Lo podemos resumir como el archivo donde indicamos que servidores son los que tienen el sitio web, los cuales debe balancear.
Ponemos las dos líneas de nuestros dos servidores. Le ponemos de nombre backend, por tanto, el proxy pass será el mismo.
En este caso no definimos el orden que el balanceador tendrá a la hora de dirigir las peticiones del servidor.
Por defecto utilizara el algoritmo round robin, que alternativamente va enviando cada petición a uno diferente de forma equitativa.
En esta práctica he cambiado el contenido de la aplicación, añadiendo un "1" y un "2" en el texto "DEMO APP" en los distintos servidores, por lo que a la hora de actualizar podemos ver como aplica esta regla y cada vez nos muestra un servidor diferente sin tener en cuenta la cantidad de peticiones, saturación o cualquier otro algoritmo.
