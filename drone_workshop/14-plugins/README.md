# Plugins

Drone permite el uso de plugins. Los plugins no son mas que cierto tipo de
contenedores preparados para realizar una tarea especifica. Los plugins que
hay actualmente disponibles para Drone se encuentran listados en su
[web dedicada a ello][1].

Nosotros podemos tambien crear nuestros propios plugins, ya que como se ha
mencionado anteriormente, son simplemente contenedores preparados para
realizar una tarea especifica. Si queremos crear un plugin tenemos una guía
en la [documentación de Drone][2].

En este ejemplo veremos el uso del plugin `Volume Cache` que permite
disponer de una cache de almacenamiento entre ejecuciones del pipeline. Esto
es especialmente útil cuando se compila ya que disponer de una cache con
elementos precompilados acelera el proceso. Este plugin de cache es el mas
sencillo, existe uno bastante mas potente que permite trabajar con
diferentes backends de almacenamiento de datos llamado [drone-cache][3] que
puede resultar mas adecuado en entornos productivos.

NOTA: Este ejemplo requiere que el repositorio sea marcado como _trusted_ en
Drone puesto que usa volumenes para trabajar.

[1]: http://plugins.drone.io/
[2]: https://docs.drone.io/plugins/overview/
[3]: https://github.com/meltwater/drone-cache
