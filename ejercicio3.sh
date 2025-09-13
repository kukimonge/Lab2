#!/bin/bash

# EJERCICIO 3 - Scripting y servicios.
# Este script monitorea continuamente un directorio en busca de eventos de creación, modificación y eliminación.

# Verificamos que el comando 'inotifywait' está instalado en el sistema.
if [[ -z $(command -v inotifywait 2>/dev/null) ]]; then
    echo ""
    echo "ERROR: No se pudo iniciar el monitoreo. Verifique que inotify-tools está instalado."
    echo ""
    exit 1
fi

# Configuramos una variable local para el directorio a monitorear y para el archivo log donde se van a registrar los eventos monitoreados.
directorio="/home"
log="log_monitoreo_home.txt"
