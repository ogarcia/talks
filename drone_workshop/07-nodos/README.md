# Selección de Nodos

El funcionamiento de Drone se basa en un servidor que distribuye los
trabajos y uno o mas agentes que son los que realmente ejecutan el pipeline.
Cuándo tenemos varios agentes puede darse el caso de que algunos se ejecuten
en un hardware mas potente y otros en otro mas comedido. La selección de
nodo es interesante para poder forzar a que ciertos pipelines se ejecuten en
nodos concretos.

## Configuración del Nodo

Para poder seleccionar el Nodo desde el pipeline previamente debemos
configurarlo agregándole etiquetas. Las etiquetas no son mas que pares
clave-valor que se almacenan en la variable `DRONE_RUNNER_LABELS` de la
siguiente forma.

```
DRONE_RUNNER_LABELS=disk:ssd,memory:high,cpu:fast
```

Por ejemplo, un _docker compose_ para arrancar un agente con estas etiquetas
sería como el siguiente.

```yaml
drone-agent-bis:
  image: drone/agent
  depends_on:
  - drone-server
  volumes:
  - /var/run/docker.sock:/var/run/docker.sock
  environment:
  - DRONE_RPC_SERVER=http://drone-server
  - DRONE_RPC_SECRET=theultrasecretpassphrase
  - DRONE_RUNNER_LABELS=disk:ssd,memory:high,cpu:fast
```

Podemos ponerle todas las etiquetas que consideremos necesarias.

## Selección en el pipeline

Una vez arrancado el nodo o nodos con las etiquetas, podemos agregar una
sección `node` en nuestro pipeline indicando las claves y los valores.

```yaml
node:
  disk: ssd
  memory: high
  cpu: fast
```

En el ejemplo anterior el pipeline se ejecutara en el nodo o nodos que
tengan configuradas las etiquetas mostradas.

Es importante tener en cuenta que deben coincidir siempre todas las
etiquetas con sus valores. En los ejemplos al arrancar el nodo estamos
especificando tres etiquetas con tres valores, en el pipeline tienen que
aparecer exactamente las mismas tres etiquetas con los mismos valores. Si
alguna de ellas no estuviese definida en el pipeline, entonces no
progresaría la construcción del mismo.
