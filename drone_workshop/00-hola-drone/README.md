# Hola Drone

Este repositorio contiene el ejemplo básico de hacer un echo usando el
contenedor de Alpine Linux.

## Funcionamiento de los pasos del pipeline

Los comandos del paso se transforman en un script _sh_ y se ejecutan como
entrypoint del contenedor. En este ejemplo lo que sucedería es que el
comando `echo "Hola drone"` se transformaría en el siguiente script.

```sh
#!/bin/sh
set -e

echo "Hola drone"
```

Y se ejecutaría de la siguiente manera.

```
docker run --entrypoint=build.sh alpine
```

## Cambios en el ejercicio

Añadir un comando `ls -l /etc` para entender que son comandos de shell.

Añadir un comando `cat /etc/alpine-release` para ver que realmente estamos
usando Alpine Linux.

Añadir un comando inventado o un `false` para ver como termina con error.
