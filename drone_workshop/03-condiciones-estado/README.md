# Condiciones por estado

Este ejemplo muestra como podemos ejecutar diferentes pasos del pipeline
dependiendo del estado, es decir, si alguno de los pasos falla.

Hay que tener en cuenta que:

1. La ejecución del pipeline se marcará siempre como fallida aunque tengamos
   pasos correctivos que se ejecuten ante un fallo.
2. Los pasos marcados para ejecutar en fallo se ejecutaran siempre que hay
   un fallo, independientemente de cuando este se produzca, es decir, que si
   tenemos mas de un paso que se ejecuta en fallo y a su vez falla, el
   procesado del pipeline no se detiene.
3. Realmente el pipeline solo tiene dos condiciones de estado, bien o mal.
   Por lo que realmente no nos permite realizar subdivisiones condicionales.
   Tendríamos que crear pipelines distintos y usar triggers si quisiéramos
   hacer algo mas avanzado.
