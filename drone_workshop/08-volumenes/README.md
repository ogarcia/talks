# Volumenes

Este ejemplo muestra como se pueden manejar volumenes al levantar los
contenedores docker en los pasos del pipeline. Esto requiere que el
repositorio en Drone haya sido configurado como _trusted_ puesto que nada
impediría que se montase el directorio raiz y se leyesen datos del mismo.

Solamente los administradores de Drone pueden establecer un repositorio como
_trusted_.

## Sobre el privileged

En el paso del ejemplo que se monta el volumen de Docker podemos ver que hay
un `privileged: true`, esto solamente aplica en hosts que tengan AppArmor
o SELinux y se utiliza para darle permisos elevados al contenedor de tal
manera que los binarios que se ejecutan en él tengan los mismos privilegios
que si se estuviesen ejecutando fuera del mismo.
