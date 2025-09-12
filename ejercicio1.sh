#!/bin/bash

# EJERCICIO 1 - Scripting, usuarios y permisos.
# Este script permite modificar los usuarios, grupos y permisos asociados a un archivo.

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

# Verificamos si el grupo especificado existe en el sistema.
# NOTA: Usamos 'getent group' para obtener la lista de grupos existentes, y 'grep' para buscar el grupo especificado.
if [[ -n $(getent group | grep "^$grupo:") ]]; then
    # Si el grupo existe, se muestra un mensaje.
    echo ""
    echo "AVISO: El grupo '$grupo' ya existe en el sistema."
else
    # Si el grupo no existe, se agrega al sistema.
    groupadd "$grupo"
fi

# Verificamos si el usuario especificado existe en el sistema.
# NOTA: Usamos 'getent passwd' para obtener la lista de usuarios existentes, y 'grep' para buscar el usuario especificado.
if [[ -n $(getent passwd | grep "^$usuario:") ]]; then
    # Si el usuario existe, se muestra un mensaje y se asigna al grupo especificado.
    echo ""
    echo "AVISO: El usuario '$usuario' ya existe en el sistema."
    usermod -aG "$grupo" "$usuario"
else
    # Si el usuario no existe, se agrega al sistema y se asigna al grupo especificado.
    useradd "$usuario"
    usermod -aG "$grupo" "$usuario"
fi

# Asignamos el archivo al usuario y grupo especificado, utilizando 'chown'.
chown "$usuario":"$grupo" "$rutaArchivo"

# Asignamos permisos de lectura, escritura y ejecución para los diferentes tipos de usuarios, utilizando 'chmod' con notación octal.
chmod 740 "$rutaArchivo"

# Mostramos la información del archivo, incluyendo el propietario, grupo y permisos.
echo ""
echo "Información del archivo '$rutaArchivo':"
echo "  Propietario: $usuario"
echo "  Grupo: $grupo"
echo "  Tipo de archivo y permisos: $(ls -l "$rutaArchivo" | awk '{print $1}')"
echo ""
