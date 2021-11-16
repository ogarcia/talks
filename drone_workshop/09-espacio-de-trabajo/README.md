# Espacio de trabajo

En este ejemplo veremos como funciona Drone con el espacio de trabajo. Por
defecto drone define un volumen como espacio de trabajo que comparten todos
los pasos del pipeline, este volumen por defecto cumple el siguiente patrón.

```
/drone/src/github.com/octocat/hello-world
```

La parte `/drone/src` es fija, luego viene el servidor del repositorio, el
usuario y, por último, el nombre del repositorio.

```
/drone/src/<nombre_del_host>/<usuario>/<repositorio>
```

Por ejemplo para el `hola-drone` el patrón sería el siguiente.

```
/drone/src/<nombre_del_host>/drone/hola-drone
```

Podemos modificar el espacio de trabajo con la siguiente definición.

```
workspace:
  base: /base
  path: repositorio
```

La _base_ define el punto de montaje del volumen que se va a encontrar
disponible a lo largo del pipeline y el _path_ el lugar donde se va a clonar
nuestro repositorio además de ser el directorio de trabajo. La ruta de
_path_ es relativa a _base_ puesto que se suma a ella. En nuestro ejemplo en
`/base` se monta el volumen compartido y en `/base/repositorio` tenemos
tanto el directorio de trabajo como el clonado del repositorio.
