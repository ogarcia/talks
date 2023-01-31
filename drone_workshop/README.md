# Workshop de Drone

La presentación asociada a este _Workshop_ puede encontrarse [aquí][talk].

[talk]: https://slides.com/oamor/drone-workshop

## Instalación inicial del entorno

Lo primero que necesitamos saber es el nombre de nuestra maquina, ya que es
una variable necesaria para poder ejecutar el entorno. A partir de aquí,
cada vez que veamos _${hostname}_ en los ejemplos debemos sustituirlo por el
nombre de nuestro host.

Para levantar el entorno preconfigurado con _docker-compose_ ejecutamos.

```sh
env HOST=$(hostname) docker-compose up
```

Esto nos levantará un Gogs con el SSH en el `11022` y la web en el `11080`
y el acceso web de Drone en el `11090`.

Entramos en http://${hostname}:11080 y realizamos una configuración inicial de
Gogs.

1. En _Tipo de base de datos_ seleccionamos _SQLite3_ en _Ruta_ dejamos el
   valor que nos sugiere `data/gogs.db`.
2. En _Dominio_ ponemos el nombre de nuestro host.
3. En _Puerto SSH_ ponemos en donde esta escuchando externamente el docker
   de Gogs, esto es `11022`.
4. El _Puerto HTTP_ lo dejamos como está ya que este hace referencia a la
   propia maquina, y dentro del docker el gogs escucha en el `3000`.
5. En _URL de la aplicación_ ponemos nuestro hostname y el puerto donde esta
   escuchando externamente la aplicación web de Gogs, ej.
   `http://${hostname}:11080`.
6. En la _Configuración opcional_, seccion _Configuración del servidor
   y otros servicios_, seleccionamos _Activar el modo Sin Conexión_, esto
   nos activará tambien la opción _Desactivar el servicio Gravatar_.
7. En la sección _Configuración de la cuenta de administrador_ introducimos
   los valores para crear una cuenta. En este caso como se trata de un
   ejercicio lo mejor es meter de nombre de usuario y contraseña `drone`
   y de dirección de correo `drone@example.com`.

Por último hay una configuración que debemos realizar a mano ya que no es
posible hacerla ni con el instalador ni con la interfaz web. Esta
configuración es necesaria para que Gogs permita enviar webhooks
a direcciones locales, ya que por seguridad no lo permite. Para ello haremos
lo siguiente.

1. Detenemos la ejecución del entorno _docker-compose_.
2. Con `docker inspect` revisaremos donde esta el volumen
   `drone_workshop_gogs-data`.
   ```sh
   docker volume inspect drone_workshop_gogs-data
   ```
   Esto nos indicará el punto de montaje (_Mountpoint_) donde se encuentra
   el volumen.
3. Iremos a la ruta especificada, normalemnte será algo similar
   a `/var/lib/docker/volumes/drone_workshop_gogs-data/_data` y dentro de
   esa ruta iremos a `gogs/conf` donde tendremos un fichero `app.ini`.
4. Editaremos ese fichero y bajo la sección `[security]` introduciremos una
   nueva entrada `LOCAL_NETWORK_ALLOWLIST` con el valor de nuestro
   `${hostname}`.
   ```ini
   [security]
   LOCAL_NETWORK_ALLOWLIST = ${hostname}
   ```
5. Levantamos de nuevo el entorno con _docker-compose_.

Una vez hecho esto, ya tendremos el entorno 100% configurado para trabajar.

## Creación del repositorio

Una vez que tengamos el sistema configurado. Entramos en Gogs y nos vamos
a `Crear (+) -> Nuevo repositorio`.

En nombre de repositorio ponemos `hola-drone` y en descripción `Hola Drone`
e inicializaremos el repositorio con las plantillas para que no quede vacío
y podamos subir ficheros a través de la interfaz web.

Entramos en Drone en http://${hostname}:11090, nos autenticamos con el usuario
`drone` (no es necesario completar el registro, simplemente pulsar enviar)
y activamos el repositorio `hola-drone`.

Volvemos a Gogs y en la configuración del repositorio, en el apartado de
Webhooks veremos que Drone ha metido un webhook propio. Esto es lo que Drone
va a usar para obtener la notificación de los cambios en el repositorio.

Subimos al repositorio el fichero `.drone.yml` que hay en `hola-drone`.

## Sobre el promote

El evento de promote solo se puede dar desde la línea de comandos y esta
pensado precisamente para crear una entrada en el pipeline con un
condicional que solo se ejecute en ese tipo de eventos.

En el ejercicio de _otras-condiciones_ hay un ejemplo de _promote_.
