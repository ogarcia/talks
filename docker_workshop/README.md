# Docker Workshop

La presentación asociada a este _Workshop_ puede encontrarse [aquí][talk].

[talk]: https://slides.com/oamor/docker-workshop

## Instalación

Para este _workshop_ es necesario instalar `docker` y `docker-compose`.

En _Debian_
```
sudo apt install docker docker-compose
```

En _Arch Linux_
```
sudo pacman -S docker docker-compose
```

A mayores podemos agregar a nuestro usuario al grupo _docker_ para no tener
que lanzar todos los comandos como root.
```
sudo gpasswd -a $USER docker
```

## Comandos básicos

### El comando docker

Si lanzamos simplement `docker` veremos una ayuda con los posibles comandos.

### Búsqueda de imágenes Docker

Por norma general al comenzar a usar Docker se suele partir de imágenes ya
existentes. Si bien con la experiencia y el uso es posible que construyamos
nuestras propias imágenes (e incluso las almacenemos en nuestro propio
registro) inicialmente lo mas sencillo es buscarlas en los repositorios
oficiales. Los mas importantes son.

* [Docker Hub][1]: Es el único soportado de manera oficial por Docker.
* [Quay][2]: Es el oficial de RedHat, muy utilizado en OpenShift.
* [GitLab][3]: No es un registro en el que puedas buscar como en los
  anteriores, pero si tu proyecto esta alojado con ellos puedes tambien
  disponer de las imágenes en el mismo lugar.
* [GitHub][4]: Funciona de manera similar al registro de GitLab.

Para realizar la búsqueda se puede utilizar el comando `docker search TERM`,
siendo _TERM_ el término a buscar. Sin embargo este comando solamente busca
en el Docker Hub y no lista los tags (versiones) de las imágenes. Por lo que
resulta mucho mas práctico buscar vía web.

[1]: https://hub.docker.com/
[2]: https://quay.io/
[3]: https://docs.gitlab.com/ee/user/packages/container_registry/
[4]: https://github.com/features/packages

### Descargar las imágnes

Para descargar las imágnes utilizaremos el comando `docker pull`, ej.
```
docker pull alpine:3.14.3
```

Este comando descargará la imagen de _Alpine Linux_ en su versión 3.14.3. Si
no se le espefica el _tag_ entonces descargará automáticamente el _tag_
_latest_ que, en imagenes oficiales, coincide siempre con la última versión
disponible.

### Lanzar la imagen

Para lanzar la imagen descargada usaremos el comando `docker run`
```
docker run -t -i --rm alpine:3.14.3
```

A este comando le hemos pasado los siguientes parámetros.

* `-t`: Asignar una pseudo-TTY (un terminal).
* `-i`: Sesión interactiva, es decir, que la entrada estándar se mantenga
  abierta para que se le puedan enviar comandos.
* `--rm`: Eliminar el contenedor al salir. Esto lo que nos permite es que
  del momento que el proceso principal del contenedor _muera_ se elimine el
  contenedor, de tal forma que a la siguiente ejecución se parta de la
  imagen limpia.

### Ver que hay en ejecución

Cuando tenemos uno o varios contenedores en ejecución podemos lanzar la
orden `docker ps` para listarlos.

Si queremos además ver los contenedores que están detenidos debemos pasarle
el modificador `-a`.
```
docker ps -a
```

### Persistir los cambios en Docker (método no muy usado)

Existe una forma de realizar cambios en un contenedor y persistirlos a una
nueva imagen, este método no suele usarse porque normalmente en su lugar se
suelen utilizar _Dockerfiles_ y la orden `docker build` (que veremos mas
adelante).

Veamos un ejemplo.
```
docker run -t -i --name gpul alpine:3.14.3
apk add -U nginx
echo "daemon off;" >> /etc/nginx/nginx.conf
exit

docker commit gpul gpulimage:1
docker rm gpul
```

Lo que hemos hecho ha sido lo siguiente.

1. Arrancamos un contenedor con nombre _gpul_ basado en Alpine.
2. Dentro del contenedor instalamos _nginx_.
3. Le hacemos una pequeña configuración a _nginx_ para que, si lo
   ejecutamos, se quede en primer plano.
4. Salimos del contenedor.
5. Con la orden `docker commit` persistimos los cambios hechos en nuestro
   contenedor a una nueva imagen de Docker a la que llamamos _gpulimage_
   y a la que le asignamos el _tag_ 1.
6. Borramos el contenedor _gpul_.

Ahora podemos lanzar lo siguiente.
```
docker run -t -i --rm -p 8080:80 gpulimage:1 nginx
```

Con esto arrancaríamos la nueva imagen _gpulimage_ indicandole al sistema
que queremos redireccionar el puerto 8008 de la máquina anfitrión al 80 del
contenedor y que el comando a ejecutar es _nginx_. Como en la configuración
que hicimos antes le indicamos a _nginx_ que queremos que quede en primer
plano, el contenedor se mantendrá en ejecución hasta que lo detengamos.
Podemos hacer ahora un `curl -v http://localhost:8080` para ver como,
efectivamente, escucha nginx (nos retorna un 404 puesto que la configuración
por defecto de Alpine no expone ninguna página).

## Trabajar con Docker

### Arrancar procesos como demonios y detenerlos

Aprovechando la imagen recien creada _gpulimage_ podemos lanzarla en segundo
plano (como un demonio) simplemente modificando ligeramente la orden run.
```
docker run -d -p 8080:80 --name gpul gpulimage:1 nginx
```

En este caso estamos usando los siguientes parámetros.

* `-d`: arrancar la imagen en segundo plano como demonio.
* `-p 8080:80`: exponer el puerto 80 del contenedor en el 8080 de la máquina
  anfitrión.
* `--name gpul`: le damos un nombre al contenedor, esto no es obligatorio,
  pero si nos ayuda mucho a localizarlo después.

Como vemos a mayores le pasamos el comando `nginx` para que ejecute dicho
comando en lugar de un shell.

Si ahora hacemos un `docker ps` veremos que el contenedor se encuentra en
ejecución.
```
% docker ps -a
CONTAINER ID   IMAGE         COMMAND   CREATED         STATUS        PORTS                                   NAMES
ebee878b46f4   gpulimage:1   "nginx"   2 seconds ago   Up 1 second   0.0.0.0:8080->80/tcp, :::8080->80/tcp   gpul
```

Podemos probar a hacer un `curl` y vemos con responde _nginx_.

Para detener el contenedor utilizaremos la orden `docker stop CONTAINER`
y para arrancarlo de nuevo `docker start CONTAINER`.
```
% docker stop gpul
gpul

% docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

% docker ps -a
CONTAINER ID   IMAGE         COMMAND   CREATED         STATUS                      PORTS     NAMES
ebee878b46f4   gpulimage:1   "nginx"   3 minutes ago   Exited (0) 28 seconds ago             gpul
```

Como podemos ver, una vez detenido el contenedor no nos aparece al hacer un
`docker ps` y, evidentemente, _nginx_ no responde. Si lanzamos un `docker
start gpul` lo iniciaríamos de nuevo y volvería a responder.

Mientras no destruyamos el contenedor, todo lo que se genera dentro del
mismo en las diferentes ejecuciones se mantiene.

### Ejecutar órdenes en contenedores en ejecución

Si tenemos un contenedor en ejecución lo que realmente tenemos es un binario
ejecutandose en _primer plano_. Si ese contenedor tiene otros binarios (o
tiene un interprete de órdenes) podemos ejecutarlo en paralelo con la orden
`docker exec CONTAINER COMMAND`.
```
docker exec -t -i gpul sh
```

En este caso le estamos pasando los parámetros ya conocidos de `-t` y `-i`
y a mayores le estamos indicando que ejecute la orden `sh` (un interprete de
órdenes), lo que nos dará una shell interactiva dentro del propio
contenedor.

### Inspeccionar

Con la orden `docker inspect NAME|ID` podemos inspeccionar elementos de
docker, esto es váido tanto para contenedores como imágenes, redes, etc.

La orden _inspect_ nos da información detallada del elemento, como puede ser
puertos redirigidos, capas que conforman su imagen, volumenes de datos
montados, etc.

### Eliminar contenedores

Para eliminar un contenedor primero es necesario detenerlo. Por ejemplo, si
tenemos en ejecución el contenedor _gpul_ podemos eliminarlo con la orden
`docker rm CONTAINER` de la siguiente manera.
```
% docker stop gpul
gpul

% docker rm gpul
gpul
```

### Volviendo a las imágenes

El comando `docker image` tiene a su vez un pequeño conjunto de subcomandos
para trabajar con las imágenes.

* `docker image ls`: lista las imágenes que tenemos en local.
* `docker image save`: nos permite almacenar una imagen como un `.tar` para
  que podamos trasladarla (por defecto sale a STDOUT).
* `docker image load`: es el contrario a _save_, nos permite importar la
  imagen de un `.tar` (por defcto desde el STDIN).
* `docker image import`: nos permite importar un contenedor como una imagen
  desde un `.tar` previamente tenemos que exportar el contenedor con la
  órden `docker container export`.
* `docker image pull`: ya hemos visto su alias `docker pull`, nos permite
  descargar una imagen del registro.
* `docker image push`: tiene un alias `docker push`, nos permite enviar una
  imagen al registro.
* `docker image history`: muestra el historial de capas que conforman la
  imagen, interesante para saber cuando se crearon las mismas ya que da
  fechas.
* `docker image inspect`: alias de `docker inspect`, es útil si tenemos dos
  elementos con el mismo nombre, ya que con esto nos aseguramos de que
  estamos inspeccionando la imagen.
* `docker image tag`: nos permite ponerle una nueva etiqueta a una imagen ya
  existente.
* `docker image rm`: tiene un alias `docker rmi`, nos permite eliminar una
  imagen.
* `docker image prune`: hace limpieza, elimina imagenes no utilizadas o que
  no tienen tag.

### Volúmenes

Por definición los contenedores no persisten sus datos. Se ejecutan a partir
de las imágenes y lo normal suele ser que una vez finalice su ejecución se
destruyan para volver a ejecutarse de una manera limpia. Esto produce que
todo lo que hayan creado desaparezca con ellos. Para evitar la pérdida de
datos utilizamos los volúmenes.

La forma mas sencilla de utilizar un volumen sería la siguiente.
```
docker run -t -i --rm -v /tmp/volumen:/volumen alpine:3.14.3
```

Al pasarle el parámetro `-v` le estamos indicando que queremos utilizar un
volumen. En este caso estamos usando un volumen simple basado en un
directorio, de tal forma que montamos el directorio `/tmp/volumen` de la
maquina anfitrión en `/volumen`. Una vez dentro del contenedor podemos leer
y escribir en `/volumen` y los datos serán persistentes aunque eliminemos el
contenedor.

Si bien es posible montar volumenes de directorios de manera directa. La
forma _correcta_ de usarlos es utilizando el comando `docker volume`.

* `docker volume create`: crear un volumen.
* `docker volume ls`: listar los volumenes.
* `docker volume inspect`: inspeccionar un volumen.
* `docker volume rm`: eliminar un volumen.
* `docker volume prune`: eliminar todos los volumenes que no esten en uso.

Para crear y usar un volumen.
```
docker volume create gpulvolume
docker run -t -i --rm -v gpulvolume:/volumen alpine:3.14.3
```

Si inspeccionamos el volumen creado con la orden `docker volume inspect
gpulvolume` podemos ver donde se ha creado y acceder directamente a sus
datos desde el sistema de archivos.

### Redes

Hemos visto que con la orden `-p` podemos redireccionar un puerto de la
máquina anfitrión al contenedor. A mayores podemos crear redes para que los
contenedores se comuniquen entre si sin necesidad de redireccionar puertos,
esto se hace con `docker network`. Los comandos mas interesantes son.

* `docker network create`: crea una red.
* `docker network ls`: lista las redes creadas.
* `docker network inspect`: inspeccionar una red.
* `docker network rm`: eliminar una red.

Para crear una red y utilizarla.
```
docker network create gpulnet
docker run -d --network gpulnet --name gpulnginx gpulimage:1 nginx
docker run -t -i --rm --network gpulnet alpine:3.14.3
# apk -U add curl
# curl -v http://gpulnginx
```

En los comandos anteriores primero creamos la red _gpulnet_ para luego
arrancar dos contenedores que la usan. El primero, _gpulnginx_, levanta el
demonio de _nginx_ y el segundo funciona como cliente. Al ejecutar en el
segundo contenedor un _curl_ vemos que alcanza el primero.

## Dockerfile

Anteriormente hemos visto que con `docker commit` podíamos crear imagenes
a partir de contenedores. Sin embargo el método mas eficiente para hacer
esto es usar un _Dockerfile_ puesto que nos asegura la reproducibilidad.

Si revisamos el fichero `dockerfiles/alpine-nginx/Dockerfile` veremos que
realmente se trata de un listado de comandos a ejecutar. En este caso lo que
hace es lo siguiente.

1. Indica que debe partir de `alpine:3.14.3`.
2. Ejecuta un upgrade de los paquetes.
3. Instala _nginx_ y realiza una configuración del mismo para que quede en
   primer plano al ejecutarse.
4. Indica que el comando a ejecutar por defecto en el contenedor sea
   `/usr/sbin/nginx`.

Si ahora lanzamos lo siguiente.
```
docker build -t gpulnginx:1 .
```

Creamos una imagen con nginx que podemos lanzar de la siguiente manera.
```
docker run -t -i --rm -p 8080:80 gpulnginx:1
```

Podemos lanzar un `curl` contra el 8080 de la maquina anfitrión y veremos
que nginx esta ejecutandose.

En `dockerfiles/alpine-nginx-complete` tenemos un ejemplo mas completo de
como crear una imagen con nginx.

### Sobre el scratch

Si queremos partir realmente de una imagen limpia (un contenedor
completamente vacío) podemos usar `scratch`. En el directorio
`dockerfiles/scratch-busybox` podemos ver un ejemplo. Para crear la imagen
debemos ejecutar lo siguiente.
```
TEMPDIR=$(mktemp -d)
mkdir -p ${TEMPDIR}/bin ${TEMPDIR}/sbin \
  ${TEMPDIR}/usr/bin ${TEMPDIR}/usr/sbin
curl https://busybox.net/downloads/binaries/1.31.0-defconfig-multiarch-musl/busybox-x86_64 \
  > ${TEMPDIR}/usr/bin/busybox
chmod 755 ${TEMPDIR}/usr/bin/busybox
tar cvf busybox.tar -C ${TEMPDIR} .
rm -r ${TEMPDIR}
docker build -t gpulbb .
rm busybox.tar
```

Esto es lo que hemos hecho.

1. Creamos un directorio temporal y almacenamos la ruta en una variable.
2. Dentro de ese directorio temporal creamos los directorios `bin`, `sbin`,
   `usr/bin` y `usr/sbin`.
3. Descargamos el binario de busybox y lo guardamos en el directorio
   temporal en `usr/bin` como `busybox`.
4. Hacemos el comando `busybox` ejecutable.
5. Creamos un fichero tar con el contenido del directorio temporal.
6. Borramos el directorio temporal.
7. Hacemos el `docker build` esto hace lo siguiente.
   1. Parte de `scratch`.
   2. Añade el fichero tar al contenedor, el comando `ADD` extrae
      automáticamente el contenido del tar.
   3. Ejecutamos el comando `busybox --install` esto crea todos los enlaces
      de _busybox_ para tener todos los comandos.
   4. Indicamos que el comando a ejecutar por defecto es `sh`.
8. Borramos el fichero tar.

Ahora podemos lanzar la imagen recien creada.
```
docker run -t -i --rm gpulbb
```

## Un ejemplo real

Vamos a ver como se montaría un sistema para alojar un _WordPress_ de manera
sencilla. Para ello necesitamos un [MariaDB][mdb] y el propio [WordPress][wp].
```
docker volume create gpul-wordpress-db
docker volume create gpul-wordpress-data
docker run -d --name gpul-wordpress-db \
  --mount source=wordpress-db,target=/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=secret \
  -e MYSQL_DATABASE=wordpress \
  -e MYSQL_USER=manager \
  -e MYSQL_PASSWORD=secret \
  mariadb:10.3.9
docker run -d --name gpul-wordpress \
  --link gpul-wordpress-db:mysql \
  --mount source=gpul-wordpress-data,target=/var/www/html \
    -e WORDPRESS_DB_USER=manager \
    -e WORDPRESS_DB_PASSWORD=secret \
    -p 8080:80 \
    wordpress:5.8.1
```

Esto es lo que hemos hecho.
1. Crear un volumen para almacenar la base de datos.
2. Crear un volumen para almacenar los datos que WordPress genera en el
   sistema de archivos.
3. Levantar un contenedor con el servidor de BBDD MariaDB al que le
   indicamos que utilice el volumen previamente creado. Aqui se introduce un
   cocepto _nuevo_ el `-e` que se utiliza para definir el valor de una
   variable de entorno. Normalmente las variables de entorno se utlizan en
   Docker para configurar el software que se ejecuta dentro del contenedor.
4. Levantar un contenedor con WordPress al que le indicamos que se conecte
   al contenedor de MariaDB y que utilice el volumen previamente creado.

Si bien de esta manera funciona, no es el mejor modo de ejecutarlo puesto
que el uso de `--link` esta desaconsejado. En su lugar lo mejor es crear una
red.
```
docker stop gpul-wordpress-db gpul-wordpress
docker rm gpul-wordpress-db gpul-wordpress
docker network create gpul-wordpress
docker run -d --name gpul-wordpress-db \
  --mount source=wordpress-db,target=/var/lib/mysql \
  --network gpul-wordpress \
  -e MYSQL_ROOT_PASSWORD=secret \
  -e MYSQL_DATABASE=wordpress \
  -e MYSQL_USER=manager \
  -e MYSQL_PASSWORD=secret \
  mariadb:10.3.9
docker run -d --name gpul-wordpress \
  --network gpul-wordpress \
  --mount source=gpul-wordpress-data,target=/var/www/html \
    -e WORDPRESS_DB_USER=manager \
    -e WORDPRESS_DB_PASSWORD=secret \
    -e WORDPRESS_DB_HOST=gpul-wordpress-db \
    -p 8080:80 \
    wordpress:5.8.1
```

En este último ejemplo hemos hecho exactamente lo mismo que en el ejemplo
anterior, solo que en este caso estamos usando una red para conectar ambos
contenedores entre si. Cómo no estamos usando la opción `--link` la BBDD no
se encuentra en el _host_ `mysql`, es por eso que debemos indicarle el valor
de `WORDPRESS_DB_HOST`.

[mdb]: https://hub.docker.com/_/mariadb
[wp]: https://hub.docker.com/_/wordpress

## El ejemplo real usando Docker Compose

Con Docker Compose podemos crear un fichero llamado `docker-compose.yaml` en
donde podemos pasar todos los parámetros que necesitamos para levantar
nuestro entorno de contenedores.

Por ejemplo, para usar `docker-compose/gpul-wordpressi/docker-compose.yaml`
ejecutamos (se le puede pasar la orden `-d` para que continue la ejecución
en segundo plano).
```
docker-compose up
```

Tenemos otras ordenes útiles.

* `docker-compose ps`: hace un `docker ps -a` de los contenedores
  referenciados en el fichero `docker-compose.yaml`.
* `docker-compose stop`: detiene los contenedores si los hemos arrancado en
  modo demonio.
* `docker-compose down`: elimina todo lo creado por docker-compose
  a excepción de los volúmenes, si queremos eliminarlos tambien podemos
  pasarle la orden `-v`.

## Notas finales

Existen otras implementaciones para trabajar con contenedores en nuestras
máquinas como por ejemplo [Podman][podman]. O incluso mucho mas grandes como
[Kubernetes][k8s].

Podman ofrece otras funcionalidades como ser _rootless_ (sin _root_),
multidemonio o poder arrancar pods (contenedores múltiples al estilo
Kubernetes), pero eso ya es un uso mas avanzado del mundo de los
contenedores.

[podman]: https://podman.io/
[k8s]: https://kubernetes.io/

## ¡Bonus! Portainer

Existe un software muy visual para manejar contenedores llamado
[Portainer][pce]. Para ejecutarlo simplemente lanzamos lo siguiente.
```
docker volume create portainer_data
docker run -d -p 8000:8000 -p 9443:9443 --name portainer \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce:latest
```

Una vez lanzado podemos acceder a él con un navegador en
https://localhost:9443 (certificado autofirmado).

[pce]: https://github.com/portainer/portainer
