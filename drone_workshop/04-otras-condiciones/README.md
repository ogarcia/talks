# Condiciones por rama, referencia, evento del repositorio, objetivo, etc.

Este ejemplo muestra como se pueden ejecutar de manera condicional pasos del
pipeline dependiendo de la rama en la que nos encontremos, referencia,
evento generado en el repositorio, objetivo, instancia o, incluso, el mismo
repositorio.

Introducir el mismo `.drone.yml` en la rama `master` y en `develop` para ver
que dependiendo de la rama ejecuta una cosa u otra. Agregarle tags para ver
como ejecuta los pasos asociados al etiquetado.

Tambien podemos ver que si creamos un tag que empiece por `v` se ejecuta el
paso `solo cuando se genera una tag de versión`.

## Sobre el promote

Si instalamos el CLI podemos probar el _promote_, es decir, el comando que
nos permitiría ejecutar la parte del pipeline que publicaría los cambios en
el entorno indicado.

Primero sacamos la lista de builds ya que nos hace falta el número de build
del que queremos hacer el deployment.

```
drone build ls drone/condiciones-evento
```
Hacemos el _promote_ indicando el build y el entorno. Por ejemplo.

```
drone build promote drone/condiciones-evento <build> pro
drone build promote drone/condiciones-evento <build> pre
drone build promote drone/condiciones-evento <build> dev
```

NOTA: Si queremos sacar unicamente el número del último build podemos usar
esta forma.

```
drone build ls --limit 1 --format "{{ .Number }}" drone/condiciones-evento
```
