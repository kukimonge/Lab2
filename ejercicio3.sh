#!/bin/bash

# EJERCICIO 3 - Scripting y servicios.
# Este script monitorea continuamente un directorio en busca de eventos de creación, modificación y eliminación.

# Configuramos una variable local para el archivo log donde se van a registrar los eventos monitoreados.
log="log_monitoreo_home.txt"

# Detenemos el script y mostramos un mensaje de error en el archivo log si el comando 'inotifywait' no está instalado en el sistema.
if [[ -z $(command -v inotifywait 2>/dev/null) ]]; then
    echo "ERROR: No se pudo iniciar el monitoreo. Verifique que inotify-tools está instalado." > "$log"
    exit 1
fi

# Configuramos el archivo log para registrar los eventos monitoreados.
echo "MONITOREO DEL DIRECTORIO /home - $(date +%d/%m/%Y)" > "$log"
echo "" >> "$log"
echo "FECHA Y HORA          | ARCHIVO                      |  EVENTO  " >> "$log"
echo "----------------------+------------------------------+----------" >> "$log"

# Iniciamos el monitoreo del directorio especificado, registrando los eventos en el archivo log.
# NOTA: Usamos '--exclude' para evitar un bucle infinito al monitorear, específicamente en caso de que el script se ejecute desde /home y el archivo log se cree ahí.
inotifywait -mre create,modify,delete /home --exclude 'log_monitoreo_home\.txt' --timefmt '%d/%m/%Y %H:%M:%S' --format '%T    %w%f  %e' 2>/dev/null >> "$log"
