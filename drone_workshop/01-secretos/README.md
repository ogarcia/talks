# Secretos

Este ejemplo muestra el uso de secretos o contraseñas en Drone. Debemos
hacer lo siguiente.

1. Creamos un repositorio secretos.
2. Lo habilitamos en Drone.
3. Añadimos un secreto `user` y otro `pass` con el valor que queramos.
4. Subimos el `.drone.yml`

Podemos ver que Drone enmascara siempre el valor de los secretos en la
salida del pipeline. Es mas, si nosotros en el pipeline tuviésemos el valor
de un secreto expuesto, no aparecería en el resultado de la ejecución. Los
secretos en la vista siempre se sustituyen por `********`.

Este ejemplo muestra también que el almacenamiento es compartido en todo el
pipeline.

NOTA: Hay que tener en cuenta que cuando metemos una variable en los
comandos usando la forma `${VARIABLE}` esta es pre-procesada. Por tanto si
hacemos `echo ${VAR}`, `${VAR}` es sustituida por su valor en lugar de ser
pasada a la línea de comandos como `${VAR}`, es decir, si el contenido de
`${VAR}` fuese `ejemplo` a la línea de comandos llegaría `echo ejemplo` en
lugar de `echo ${VAR}`, es por esto por lo que debemos escapar con dos
símbolos de dolar las variables cuando queremos acceder a los secretos
utilizando la forma `${}`. Todo esto lo podemos ver en el último paso donde
además se muestran una serie de características dependientes del formato
yaml.
