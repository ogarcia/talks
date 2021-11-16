# Triggers por estado

Este ejemplo muestra como podemos condicionar un pipeline para que se
ejecute o no dependiendo del estado de ejecución de otro pipeline. Esto es
interesante a la hora de crear pipeline complejos.

A nivel funcional es muy similar a las condiciones por estado en un
pipeline, la ejecución completa se marcara fallida si cualquiera de los
pasos fallan, independientemente de que tengamos contemplados pipelines
correctivos.
