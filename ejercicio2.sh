#!/bin/bash

# EJERCICIO 2 - Scripting y procesos.
# Este script permite monitorear el consumo de CPU y memoria de un proceso específico.

# Definimos una función de ayuda para mostrar la guía de uso del script.
help() {
    echo ""
    echo "Este script permite monitorear el consumo de CPU y memoria de un proceso específico."
    echo ""
    echo "Uso: $0 [nombre_proceso]"
    echo ""
}

# Mostramos un mensaje de error si no se le pasan argumentos al script.
if [ "$#" -eq 0 ]; then
    echo ""
    echo "ERROR: Debe especificar el nombre de un proceso para monitorear."
    help
    exit 1
fi

# Configuramos una variable local para el proceso especificado por el usuario y el archivo de log donde vamos a registrar los detalles.
# NOTA: Usamos "$*" en lugar de "$1" u otras estructuras para permitir la ejecución de procesos más complejos o con opciones.
proceso="$*"

# Extraemos el nombre del proceso principal, para usarlo en el nombre del archivo de log.
# NOTA: Usamos la expresión regular para detectar si el proceso se ejecuta con 'sudo' y extraemos el nombre correcto.
if [[ "$proceso" =~ ^sudo[[:space:]] ]]; then
    procesoPrincipal=$(basename "$(echo "$*" | awk '{print $2}')")

    # Si el usuario usa 'sudo' pero no especifica ningún proceso, mostramos un mensaje de error y detenemos el script (a través de un código de salida).
    if [[ -z "$procesoPrincipal" ]]; then
        echo ""
        echo "ERROR: Debe especificar el nombre de un proceso para monitorear después de 'sudo'."
        help
        exit 1
    fi

else
    procesoPrincipal=$(basename "$(echo "$*" | awk '{print $1}')")
fi

# Ejecutamos el proceso indicado por el usuario, en segundo plano.
$proceso & 2>/dev/null

# Guardamos el PID del proceso en curso en una variable local.
pid=$!

# Configuramos un archivo de log con encabezados para registrar el consumo de CPU y memoria del proceso que se va a monitorear.
echo "TIEMPO  %CPU  %MEMORIA "
