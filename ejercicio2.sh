#!/bin/bash

# EJERCICIO 2 - Scripting y procesos.
# Este script permite monitorear el consumo de CPU y memoria de un proceso específico.

# Definimos una función de ayuda para mostrar la guía de uso del script.
help() {
    echo ""
    echo "Este script permite monitorear el consumo de CPU y memoria de un proceso específico."
    echo "Uso: $0 [comando]"
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
# Si el usuario no usa 'sudo', extraemos el nombre del proceso principal directamente.
else
    procesoPrincipal=$(basename "$(echo "$*" | awk '{print $1}')")
fi

# Ejecutamos el proceso indicado por el usuario, en segundo plano.
# NOTA: Usamos >/dev/null 2>&1 para manejar los errores manualmente y evitar que se muestren mensajes adicionales.
$proceso >/dev/null 2>&1 &

# Guardamos el PID del proceso en curso en una variable local.
pid=$!

# Validamos la ejecución del proceso tras dar tiempo para que se inicialice.
sleep 0.2
if ! kill -0 "$pid" 2>/dev/null; then
    wait "$pid" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo ""
        echo "El proceso '$procesoPrincipal' terminó justo después de iniciarse."
        echo "SUGERENCIA: Use este script para monitorear procesos de mayor duración."
        help
        exit 0
    else
        echo ""
        echo "ERROR: El proceso '$procesoPrincipal' no se pudo ejecutar."
        help
        exit 1
    fi
fi

# Configuramos el nombre del archivo de log, incluyendo la fecha actual.
log="log_$(date +%Y-%m-%d)_$procesoPrincipal.txt"

# Configuramos el archivo log para registrar el consumo de CPU y memoria mientras ejecutamos el proceso.
# NOTA: Usamos 'tee' para mostrar la información en pantalla y guardarla en el archivo de log al mismo tiempo.
echo ""
echo "CONSUMO DE CPU Y MEMORIA DEL PROCESO '$procesoPrincipal' (PID: $pid)" | tee "$log"
echo "" | tee -a "$log"
echo "FECHA Y HORA          |  %CPU  |  %MEM  |" | tee -a "$log"
echo "-----------------------------------------" | tee -a "$log"

# Definimos una función para generar gráficos una vez se termina (o interrumpe) la ejecución del script.
graph() {
    # Verificamos si el archivo de log tiene datos para poder generar los gráficos.
    # NOTA: Si el archivo tiene menos de 6 líneas (4 de cabecera y 2 de registros), el comando 'gnuplot' no puede ejecutarse correctamente, ya que se requieren al menos 2 puntos de datos para graficar.
    if [[ $(wc -l < "$log") -lt 6 ]]; then
        echo ""
        echo "ADVERTENCIA: No se pudo generar el gráfico de consumo de CPU y memoria porque el archivo log necesita al menos 2 registros válidos."
        echo ""
        exit 1
    fi

    # Verificamos si 'gnuplot' está instalado en el sistema.
    if [[ -z $(command -v gnuplot 2>/dev/null) ]]; then
        echo ""
        echo "ERROR: No se pudo generar el gráfico de consumo de CPU y memoria porque 'gnuplot' no está instalado."
        echo ""
        exit 1
    else
        # Generamos el gráfico de consumo de CPU y memoria usando 'gnuplot'.
        gnuplot -p << EOF
        set terminal png size 1200,800
        set output 'consumo_cpu_memoria_$procesoPrincipal.png'
        set title 'Consumo de CPU y memoria - $procesoPrincipal (PID: $pid)'
        set xlabel 'Tiempo'
        set ylabel 'Porcentaje (%)'
        set xdata time
        set timefmt '%Y-%m-%d_%H:%M:%S'
        set format x '%H:%M:%S'
        set grid
        set key
        plot "$log" using 1:2 with lines title 'CPU (%)', \
             "$log" using 1:3 with lines title 'Memoria (%)'
EOF
        echo ""
        echo "Puede consultar el gráfico de consumo en el archivo 'consumo_cpu_memoria_$procesoPrincipal.png'"
        echo ""
        exit 0
    fi
}

# Usamos el comando 'trap' para capturar señales de interrupción (SIGINT y SIGTERM) en el script y llamar a la función 'graph' para generar gráficos antes de salir.
trap graph SIGINT SIGTERM

# Usamos un 'while' loop para monitorear el consumo de CPU y memoria del proceso cada 10 segundos.
# NOTA: Usamos 'kill -0' para verificar si el proceso sigue en ejecución.
while kill -0 "$pid" 2>/dev/null; do
    # Extraemos el consumo de CPU y memoria del proceso usando 'ps' y 'awk'.
    consumo=$(ps -p "$pid" -o %cpu,%mem | tail -1)
    consumoCPU=$(echo $consumo | awk '{print $1}')
    consumoMEM=$(echo $consumo | awk '{print $2}')

    # Registramos la fecha y hora actuales junto con el consumo de CPU y memoria en el archivo de log.
    echo "$(date +%Y-%m-%d_%H:%M:%S)      $consumoCPU      $consumoMEM" | tee -a "$log"

    # Esperamos 5 segundos antes de la siguiente iteración.
    sleep 5
done

# Cuando el proceso finaliza, mostramos un mensaje indicando que el proceso ha terminado.
echo ""
echo "El proceso '$proceso' (PID: $pid) ha finalizado."
echo "El consumo de CPU y memoria se registró en el archivo '$log'"

# Generamos los gráficos de consumo de CPU y memoria.
graph
exit 0
