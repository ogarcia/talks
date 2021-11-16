# Triggers por rama, referencia, evento del repositorio u objetivo

Los triggers se comportan de una manera muy similar los condicionales del
ejemplo cuatro, la diferencia principal es que en lugar de actuar sobre un
paso del pipeline actuan sobre el pipeline completo.

Introducir el mismo `.drone.yml` en la rama `master` y en `develop` para ver
que dependiendo de la rama ejecuta una cosa u otra. Agregarle tags para ver
como ejecuta únicamente el pipeline asociado al etiquetado.

## Sobre el promote

El _promote_ es idéntico al ejemplo cuatro. Simplemente al tratarse de un
trigger se promociona un pipeline completo.

## Sobre la paralelización

Al haber definido diferentes pipelines en este ejemplo y no haber indicado
dependencias entre ellas, las pipelines se paralelizan entre los diferentes
nodos de ejecución que tengamos.
