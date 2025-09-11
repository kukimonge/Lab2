#!/bin/bash

# EJERCICIO 1 - Scripting, usuarios y permisos.
# Este script permite modificar la pertenencia de un archivo y los permisos asociados a usuarios y grupos.

# Definimos una función de ayuda para mostrar la guía de uso del script.
help() {
    echo ""
    echo "Uso: $0 [usuario] [grupo] [ruta/archivo]"
    echo ""
    echo "Parámetros:"
    echo "  [usuario]: Usuario que será el nuevo propietario del archivo. Crea un usuario si no existe."
    echo "  [grupo]: Grupo que será el nuevo propietario del archivo. Crea un grupo si no existe."
    echo "  [ruta/archivo]: Ruta del archivo que será asignado al usuario y grupo especificado."
    echo ""
}

# Verificamos si el usuario que corre el script es root.
# NOTA: Usamos el EUID (user ID efectivo) en lugar del UID u otras alternativas ($USER, whoami, id -u, etc.) para evitar problemas en caso de que el script se ejecute con 'sudo'.
if [ "$EUID" -ne 0 ]; then
    echo ""
    echo "ERROR: Este script requiere privilegios de root para ejecutarse."
    help
    exit 1
fi

# Verificamos que se le pasan exactamente 3 argumentos al script.
if [ "$#" -ne 3 ]; then
    echo ""
    echo "ERROR: Debe especificar 3 parámetros para ejecutar el script."
    help
    exit 1
else
    # Configuramos variables locales para los parámetros especificados por el usuario.
    usuario="$1"
    grupo="$2"
    rutaArchivo="$3"
fi

# Verificamos que se le pasa una ruta de archivo válida al script.
if [ ! -e "$rutaArchivo" ]; then
    echo ""
    echo "ERROR: El archivo no existe. Especifique una ruta de archivo válida."
    help
    exit 1
fi

echo ""
