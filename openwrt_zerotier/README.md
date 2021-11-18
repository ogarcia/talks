# Simulación Internet para OpenWRT y ZeroTier

## Máquinas

### debian-pppoe-server

Esta máquina monta el servidor PPPoE para poder ser usado desde el
enrutador, tiene dos interfaces de red.

- La eth0 esta conectada al NAT de Vagrant y vale para la gestion y para
  conectarla con nuestra red física.
- La eth1 esta conectada a una red aislada con la IP 192.168.60.69 y es la
  que simula internet.

La maquina tiene una configuración de provision que hace lo siguente.

1. Instala el servico de `pppoe-server`
2. Configura dicho servicio de manera básica para simular estar en la red de
   Telefónica. Además crea un usuario _adslppp@telefonicanetpa_ con
   contraseña _adslppp_.
3. Crea una configuración básica de _iptables_ y habilita el _IP Forwarding_
   para permitir que todo lo que llega desde el PPPoE pueda salir por la
   eth0 que es la que nos conecta con la red física.

Nota: El PPPoE configura como servidor DNS la _1.1.1.1_.

Por defecto no simula VLAN del proveedor ya que el PPPoE se levanta
directamente sobre eth1, si quisieramos simular la VLAN podríamos ejecutar
lo siguiente (simula la VLAN 6 que es la que usa Telefónica):

```
ip link add link eth1 name eth1.6 type vlan id 6
ip link set dev eth1.6 up

pppoe-server -I eth1.6 -L 10.99.99.2 -R 10.88.88.2
```

Los dos comandos `ip` crean la interfaz eth1.6 asociada a la eth1 y la
levantan y por ultimo se levanta un servidor PPPoE en dicha interfaz.

### openwrt-x64

Como oficialmente no hay ninguna imagen de OpenWRT ya creada, se acompaña la
configuración Vagrant con un script `create_box.bash` que nos crea la imagen
`openwrt-19.07.7-64.box` a partir de la imagen oficial. Simplemente tenemos
que ejecutar el script y esperar a que termine.

**ATENCIÓN**: Es necesario tener instalado el paquete `openbsd-netcat` para
que el script funcione correctamente.

La maquina monta tres interfaces de red.

- La eth0 conectada al NAT de Vagrant para la gestión. Internamente en
  OpenWRT aparece como _management_.
- La eth1 conectada a una red aislada 192.168.58.x para simular la LAN.
- La eth2 conectada a otra red aislada 192.168.60.x para simular la WAN,
  esta red coincide con la aislada de la maquina _debian-pppoe-server_ para
  que se pueda conectar al PPPoE.

Una vez arrancada la máquina solo tiene la configuración por defecto de
OpenWRT, la red LAN (eth1) se configura con el servidor DHCP habilitado
y con la IP 192.168.1.1, y la WAN con el cliente DHCP habilitado.

Para entrar en la maquina podemos hacerlo vía ssh con el comando de vagrant
o bien vía LuCI (interfaz web) en 127.0.0.1:8080.

Para configurarle el cliente PPPoE y conectar una máquina con la otra nos
vamos a Network -> Interfaces, en la interfaz WAN entramos en Edit,
cambiamos el protocolo a PPPoE y metemos el usuario
adslppp@telefonicanetpa y contraseña adslppp, guardamos los cambios y los
aplicamos y deberíamos ver que se conecta y obtiene la IP 10.88.88.88/32.

Si queremos hacer lo mismo pero usando una VLAN entonces en la configuración
de la interfaz nos tenemos que ir a la pestaña Physical Settings y en
interface escribir eth2.6 para conectar el cliente PPPoE a la eth2 pero en
la VLAN 6. Hay que tener en cuenta que en este entorno simulado no tenemos
el Switch Virtual que si tendríamos en un enrutador físico, por lo que solo
es necesario indicar la interfaz y no configurarla previamente en el Switch.

### debian-client

Si queremos usar esta maquina para simular un cliente que se conecta
a través del router primero tenemos que asignarle la IP 192.168.88.1 a la
interfaz de la red lan del router.

Esta máquina monta dos interfaces de red.

- La eth0 conectada al NAT de Vagrant para gestión.
- La eth1 que se configura en la provisión con la IP 192.168.88.88 y como
  ruta por defecto vía 192.168.88.1.

Esta es la única máquina no persistente, es decir, que si la reinciamos
debemos de ejecutar de nuevo el `vagrant provision` para reconfigurar la
red.

Si probamos ahora a realizar cualquier conexión desde esta máquina veremos
que no tiene salida a internet, esto es porque la IP que se le ha
configurado es del rango 192.168.88.0/24 cuando el OpenWRT tiene una IP LAN
del rango 192.168.1.0/24. Para que funcione tenemos que volver a la
configuración de OpenWRT y ponerle la IP 192.168.88.1 a la interfaz LAN.

### debian-zerotier-client

Esta maquina simula a un cliente que se va a conectar a través de ZeroTier,
solamente monta la interfaz NAT de Vagrant ya que no necesita de ninguna
otra para conectarse.

En la provisión se instala el demonio de ZeroTier, una vez arrancada
podemos hacer un `sudo zerotier-cli info` para ver que el demonio esta
funcionando (nos indicará que está en línea). Luego haremos un `sudo
zerotier-cli join NETWORK_ID` para conectarnos a la red (mirar en la sección
ZeroTier para mas información).

## ZeroTier

Para trabajar con ZeroTier necesitamos tener una red creada, la forma mas
sencilla y directa es utilizar el controlador central en
https://my.zerotier.com/ pero para no molestar y no tener que registrarnos
en ningun lado vamos a montar nuestro propio controlador con _ztncui_.

Hay varias maneras de levantar un ztncui, pero la mas rápida es usar el
contenedor docker de la siguiente manera.

```
docker run --rm -t -i -e HTTP_ALL_INTERFACES=yes -p 3000:3000 \
  --cap-add=NET_ADMIN keynetworks/ztncui
```

Esto nos levantará un contenedor con la interfaz web ztncui escuchando en el
puerto 3000, al levantarlo con las opciones de -t -i podemos ver el log
directamente en el terminal, y al tener un --rm nos aseguramos de que cuado
termine el ejercicio y se detenga el contenedor se borre todo. Se le debe de
pasar la variable `HTTP_ALL_INTERFACES` con valor `yes` para que escuche en
HTTP y no en HTTPS (es un ejercicio, no vamos a rompernos la cabeza con los
certificados autofirmados). En cuanto a la _capability_ de _NET_ADMIN_ es
necesaria para poder levantar el propio controlador.

El usuario por defecto es `admin` y la contraseña `password`.

Una vez dentro simplemente nos vamos a `Add network` le ponemos un nombre,
elegimos un rango de IPs para la red (o le damos a generate para que nos de
uno aleatorio) y ya tendríamos el ID de red necesario para nuestros
clientes. Tambien tendremos que configurar las rutas para hacer alcanzables
las redes tras el enrutador.
