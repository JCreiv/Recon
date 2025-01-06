#!/bin/bash

    

print_red() {
    echo -e "\033[31m$1\033[0m"
}
print_green() { 
	echo -e "\e[32m$1\e[0m"
}

ctrl_c(){
  echo -e "\n\n[!] Saliendo...\n"
  exit 1
}

# Ctrl+C
trap ctrl_c INT

#./reset.sh

figlet -f slant suprimoware
if [ -z "$1" ]; then
    echo "ERROR: No enviaste un domain name"
    echo "USO: ./main.sh <domain>"
    exit 1
fi

domain=$1
print_green "Escaneando $domain"

# Estructura de carpetas 

timestamp=$(date +"%Y-%m-%d_%H:%M:%S")
ruta_resultados=./resultados/$domain/$timestamp

mkdir -p "$ruta_resultados"
mkdir -p "$ruta_resultados/raw"
mkdir -p "$ruta_resultados/clean"

# Analisis insfraestructura

dig +short A $domain >> $ruta_resultados/clean/IP
dig +short MX $domain >> $ruta_resultados/clean/MX
dig +short TXT $domain >> $ruta_resultados/clean/TXT
dig +short NS $domain >> $ruta_resultados/clean/NS
dig +short SRV $domain >> $ruta_resultados/clean/SRV
dig +short AAAA $domain >> $ruta_resultados/clean/AAAA
dig +short CNAME $domain >> $ruta_resultados/clean/CNAME
dig +short SOA $domain >> $ruta_resultados/clean/SOA
dig +short txt _dmarc.$domain >> $ruta_resultados/clean/DMARC
dig +short txt default._domainkey.$domain >> $ruta_resultados/clean/DKIM

echo "Realizando whois"
whois $domain > $ruta_resultados/raw/whois
echo "Realizando dig"
dig $domain > $ruta_resultados/raw/dig

curl -I "https://$domain" > $ruta_resultados/raw/headers
cat $ruta_resultados/raw/headers | grep Server | awk '{print $2}' > $ruta_resultados/clean/headers_server




# Realizar whois sobre los rangos de IP y agregarlos a un archivo

while IFS= read -r ip; do
    whois -b "$ip" | grep 'inetnum' | awk '{print $2, $3, $4}' >> $ruta_resultados/clean/rangos_ripe
done < $ruta_resultados/clean/IP

# Implementacion de ctfr

ctfr -d $domain -o /tmp/dominios > $ruta_resultados/raw/ctfr

sort /tmp/dominios | uniq | httpx -o /tmp/dominiosCheck

sed -E "s|.*${domain}$|${domain}|; s|https://|""|"  /tmp/dominiosCheck | sort -u > $ruta_resultados/clean/dominios

sed -E "s|https://(.*${domain}).*|\1|; s|^${domain}$|""|"  /tmp/dominiosCheck | sort -u > $ruta_resultados/clean/subdominios

# Limpiar archivos temporales
rm /tmp/dominios
rm /tmp/dominiosCheck



# Implementacion de katana

katana -u $domain -rd 5 -o /tmp/KatanaOutput > $ruta_resultados/raw/katana

cat /tmp/KatanaOutput | unfurl paths > $ruta_resultados/clean/PATHS

cat /tmp/KatanaOutput | unfurl keys > $ruta_resultados/clean/KEYS

# Limpiar archivos temporales
rm /tmp/KatanaOutput



# Implementacion de dnsx

echo $domain | dnsx -rl 5 -recon -nc -o $ruta_resultados/raw/dnsx

awk -F '\\[A\\]' '{print $2}' $ruta_resultados/raw/dnsx | sort -u >> $ruta_resultados/clean/IP
awk -F '\\[AAAA\\]' '{print $2}' $ruta_resultados/raw/dnsx | sort -u  >> $ruta_resultados/clean/AAAA
awk -F '\\[CNAME\\]' '{print $2}' $ruta_resultados/raw/dnsx | sort -u  >> $ruta_resultados/clean/CNAME
awk -F '\\[NS\\]' '{print $2}' $ruta_resultados/raw/dnsx | sort -u >> $ruta_resultados/clean/NS
awk -F '\\[TXT\\]' '{print $2}' $ruta_resultados/raw/dnsx | sort -u >> $ruta_resultados/clean/TXT
awk -F '\\[SRV\\]' '{print $2}' $ruta_resultados/raw/dnsx | sort -u >> $ruta_resultados/clean/SRV
awk -F '\\[PTR\\]' '{print $2}' $ruta_resultados/raw/dnsx | sort -u > $ruta_resultados/clean/PTR
awk -F '\\[MX\\]' '{print $2}' $ruta_resultados/raw/dnsx | sort -u >> $ruta_resultados/clean/MX
awk -F '\\[SOA\\]' '{print $2}' $ruta_resultados/raw/dnsx | sort -u >> $ruta_resultados/clean/SOA
awk -F '\\[AXFR\\]' '{print $2}' $ruta_resultados/raw/dnsx | sort -u > $ruta_resultados/clean/AXFR
awk -F '\\[CAA\\]' '{print $2}' $ruta_resultados/raw/dnsx | sort -u > $ruta_resultados/clean/CAA


# Implementacion de subfinder

subfinder -d $domain  -rl 3 -o $ruta_resultados/raw/subfinder

cat $ruta_resultados/raw/subfinder | sort -u >> $ruta_resultados/clean/subdominios


# Implementacion de gau 

gau $domain --threads 1 --o $ruta_resultados/raw/gau 

cat $ruta_resultados/raw/gau | unfurl paths | sort -u >> $ruta_resultados/clean/PATHS

cat $ruta_resultados/raw/gau | unfurl key |sort -u >> $ruta_resultados/clean/KEYS

cat $ruta_resultados/raw/gau | unfurl keypairs | sed "s|timestamp.*|""|" | sort -u >>   $ruta_resultados/clean/KEYS

# Implementacion de cero 

cero -c 5 $domain > $ruta_resultados/raw/cero 

cat $ruta_resultados/raw/cero >> $ruta_resultados/clean/subdominios



# ORDENAR ARCHIVOS CLEAN



sort -u $ruta_resultados/clean/IP -o $ruta_resultados/clean/IP
sort -u $ruta_resultados/clean/AAAA -o $ruta_resultados/clean/AAAA
sort -u $ruta_resultados/clean/CNAME -o $ruta_resultados/clean/CNAME
sort -u $ruta_resultados/clean/NS -o $ruta_resultados/clean/NS
sort -u $ruta_resultados/clean/TXT -o $ruta_resultados/clean/TXT
sort -u $ruta_resultados/clean/SRV -o $ruta_resultados/clean/SRV
sort -u $ruta_resultados/clean/PTR -o $ruta_resultados/clean/PTR
sort -u $ruta_resultados/clean/MX -o $ruta_resultados/clean/MX
sort -u $ruta_resultados/clean/SOA -o $ruta_resultados/clean/SOA
sort -u $ruta_resultados/clean/AXFR -o $ruta_resultados/clean/AXFR
sort -u $ruta_resultados/clean/CAA -o $ruta_resultados/clean/CAA
sort -u $ruta_resultados/clean/subdominios -o $ruta_resultados/clean/subdominios
sort -u $ruta_resultados/clean/dominios -o $ruta_resultados/clean/dominios 
sort -u $ruta_resultados/clean/KEYS -o $ruta_resultados/clean/KEYS
sort -u $ruta_resultados/clean/PATHS -o $ruta_resultados/clean/PATHS



for file in "$ruta_resultados/clean"/*; do
  if [[ -f "$file" ]]; then
    # Si el archivo está vacío
    if [[ ! -s "$file" ]]; then
      echo "Eliminando archivo vacío: $file"
      rm "$file"
    # Si el archivo tiene contenido pero solo espacios o líneas vacías
    elif ! grep -q '[^[:space:]]' "$file"; then
      echo "Eliminando archivo con solo espacios o líneas vacías: $file"
      rm "$file"
    else
      echo "Archivo con contenido válido: $file"
    fi
  fi
done




# Crear el archivo con el encabezado del dominio
echo "# $domain" > "resultado.md"

echo "## Infraestructura" >> "resultado.md"

# Función para agregar contenido de archivos a una sección específica
function agregar_registros {
    tipo_registro=$1
    archivo_registro="$ruta_resultados/clean/$tipo_registro"
    
    # Solo agregar la sección si el archivo tiene contenido
    if [[ -s "$archivo_registro" ]]; then
        echo "### $tipo_registro" >> "resultado.md"
        
        # Cambiar aquí para añadir tres # al inicio de cada línea
        sed 's/^/#### /' "$archivo_registro" >> "resultado.md"
        
        echo "" >> "resultado.md"  # AñadeNS una línea en blanco para separar secciones
    fi
}

# Agregar diferentes tipos de registros
agregar_registros "NS"
agregar_registros "A"
agregar_registros "MX"
agregar_registros "TXT"
agregar_registros "CNAME"
agregar_registros "SRV"
agregar_registros "AAAA"
agregar_registros "SOA"
agregar_registros "header_server"
agregar_registros "rangos_ripe"
agregar_registros "DMARC"
agregar_registros "DKIM"


# Generar el mapa mental con markmap
markmap "resultado.md"
