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

# Si el usuario usa 'sudo' pero no especifica ningún proceso, mostramos un mensaje de error y detenemos el script (a través de un código de salida).
if [ "$proceso" = "sudo" ]; then
    echo ""
    echo "ERROR: Debe especificar el nombre de un proceso para monitorear después de 'sudo'."
    help
    exit 1
# Si el usuario usa 'sudo' junto a otro proceso, extraemos el nombre del proceso principal para usarlo en el nombre del archivo de log.
# NOTA: Usamos la expresión regular para detectar si el proceso se ejecuta con 'sudo' y extraemos el nombre correcto.
elif [[ "$proceso" =~ ^sudo[[:space:]] ]]; then
    procesoPrincipal=$(basename "$(echo "$*" | awk '{print $2}')")
else
    procesoPrincipal=$(basename "$(echo "$*" | awk '{print $1}')")
fi

# Ejecutamos el proceso indicado por el usuario, en segundo plano.
$proceso >/dev/null 2>&1 &

# Guardamos el PID del proceso en curso en una variable local.
pid=$!

# Verificamos si el proceso se inició correctamente tras dar tiempo para que se inicialice.
# NOTA: Usamos 2>/dev/null para evitar que se muestre un mensaje de error adicional si el proceso no se pudo iniciar.
sleep 1
if ! kill -0 "$pid" 2>/dev/null; then
    echo ""
    echo "ERROR: El proceso '$proceso' no se pudo ejecutar."
    help
    exit 1
fi

# Configuramos el nombre del archivo de log, incluyendo la fecha actual.
log="log_$(date +%Y-%m-%d)_$procesoPrincipal.txt"

# Configuramos el archivo log para registrar el consumo de CPU y memoria mientras ejecutamos el proceso.
# NOTA: Usamos 'tee' para mostrar la información en pantalla y guardarla en el archivo de log al mismo tiempo.
echo ""
echo "CONSUMO DE CPU Y MEMORIA DEL PROCESO '$procesoPrincipal' (PID: $pid):" | tee "$log"
echo "" | tee -a "$log"
echo "FECHA Y HORA        | %CPU | %MEM |" | tee -a "$log"
echo "-----------------------------------" | tee -a "$log"

# Usamos un 'while' loop para monitorear el consumo de CPU y memoria del proceso cada 10 segundos.
# NOTA: Usamos 'kill -0' para verificar si el proceso sigue en ejecución.
while kill -0 "$pid" 2>/dev/null; do
    # Extraemos el consumo de CPU y memoria del proceso usando 'ps' y 'awk'.
    consumo=$(ps -p "$pid" -o %cpu,%mem | tail -1)
    consumoCPU=$(echo $consumo | awk '{print $1}')
    consumoMEM=$(echo $consumo | awk '{print $2}')

    # Registramos la fecha y hora actuales junto con el consumo de CPU y memoria en elarchivo de log.
    echo "$(date +%Y-%m-%d\ %H:%M:%S) | $consumoCPU | $consumoMEM |" | tee -a "$log"

    # Esperamos 5 segundos antes de la siguiente iteración.
    sleep 5
done

# Cuando el proceso finaliza, mostramos un mensaje indicando que el proceso ha terminado.
echo ""
echo "El proceso '$proceso' (PID: $pid) ha finalizado."
echo "El consumo de CPU y memoria se ha registrado en el archivo '$log'"
echo ""
exit 0
