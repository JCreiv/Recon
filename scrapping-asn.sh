#!/bin/bash

# Verifica si se ha pasado un archivo de dominios como argumento
if [ "$#" -ne 1 ]; then
    echo "Uso: $0 domains.txt"
    exit 1
fi

# Lee el archivo de dominios línea por línea
while IFS= read -r dominio; do
    echo "Consultando: $dominio"
    
    # Llama al script de Python y pasa el dominio
    python scrapping-asn.py -d "$dominio"
done < "$1"
