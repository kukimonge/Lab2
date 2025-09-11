#!/bin/bash

# EJERCICIO 1 - Scripting, usuarios y permisos.
# Este script permite modificar la pertenencia de un archivo y los permisos asociados a usuarios y grupos.

# Verificamos si el usuario que corre el script es root.
# NOTA: Usamos el EUID (user ID efectivo) en lugar del UID u otras alternativas ($USER, whoami, id -u, etc.) para evitar problemas en caso de que el script se ejecute con 'sudo'.
if [ "$EUID" -ne 0 ]; then
    echo ""
    echo "ERROR: Este script requiere privilegios de root para ejecutarse."
    help
    exit 1
fi

echo ""
