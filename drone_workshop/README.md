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

Esto nos levantará un Gogs con el SSH en el `10022` y la web en el `10080`
y el acceso web de Drone en el `10090`.

Entramos en http://${hostname}:10080 y realizamos una configuración inicial de
Gogs.

1. En _Tipo de base de datos_ seleccionamos _SQLite3_ en _Ruta_ dejamos el
   valor que nos sugiere `data/gogs.db`.
2. En _Dominio_ ponemos el nombre de nuestro host.
3. En _Puerto SSH_ ponemos en donde esta escuchando externamente el docker
   de Gogs, esto es `10022`.
4. El _Puerto HTTP_ lo dejamos como está ya que este hace referencia a la
   propia maquina, y dentro del docker el gogs escucha en el `3000`.
5. En _URL de la aplicación_ ponemos nuestro hostname y el puerto donde esta
   escuchando externamente la aplicación web de Gogs, ej.
   `http://${hostname}:10080`.
6. Vamos a la _Configuración opcional_ a la _Configuración de la cuenta de
   administrador_ e introducimos los valores para crear una cuenta. En este
   caso como se trata de un ejercicio lo mejor es meter de nombre de usuario
   y contraseña `drone` y de dirección de correo `drone@example.com`.

Una vez hecho esto, ya tendremos el entorno 100% configurado para trabajar.

## Creación del repositorio

Una vez que tengamos el sistema configurado. Entramos en Gogs y nos vamos
a `Crear (+) -> Nuevo repositorio`.

En nombre de repositorio ponemos `hola-drone` y en descripción `Hola Drone`.

Entramos en Drone en http://${hostname}:10090, nos autenticamos con el usuario
`drone` y activamos el repositorio `hola-drone`.

Volvemos a Gogs y en la configuración del repositorio, en el apartado de
Webhooks veremos que Drone ha metido un webhook propio. Esto es lo que Drone
va a usar para obtener la notificación de los cambios en el repositorio.

Subimos al repositorio el fichero `.drone.yml` que hay en `hola-drone`.

## Sobre el promote

El evento de promote solo se puede dar desde la línea de comandos y esta
pensado precisamente para crear una entrada en el pipeline con un
condicional que solo se ejecute en ese tipo de eventos.

En el ejercicio de _otras-condiciones_ hay un ejemplo de _promote_.
