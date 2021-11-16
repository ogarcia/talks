# Servicios

Este repositorio contiene el ejemplo básico de levantar un servicio
y consultarlo desde el pipeline, todo ello usando el contenedor de Alpine
Linux.

El sleep del pipeline puede ser necesario en ciertos entornos en los cuales
el contenedor del servicio tarda en arrancar y comienza el pipeline antes de
que el propio servicio se encuentre completamente arrancado. Esto sucede
porque Drone no controla la ejecución del servicio, simplemente lanza los
comandos del mismo y los delega a un segundo plano. Tampoco controla el
retorno, es decir, aunque el servicio falle se dará siempre por buena su
ejecución.

Las pruebas al hacer curl retornan un 404 puesto que la configuración por
defecto que tiene Alpine Linux para su nginx es devolver un 404 al solicitar
la `/`.

## Sobre el detach

Drone nos permite lanzar pasos del pipeline usando `detach: true` esto viene
a ser lo mismo que se utiliza para lanzar un servicio. Lo que hace el
modificador es delegar los comandos de ese paso a un segundo plano
y continuar directamente con el siguiente. Esto puede ser útil cuando el
servicio que necesitamos lanzar en nuestro pipeline lo construimos nosotros
en un paso previo.
