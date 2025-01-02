# Domain Reconnaissance Script

Este script en Bash automatiza el proceso de reconocimiento de dominios utilizando varias herramientas de código abierto. Está diseñado para obtener información relevante sobre un dominio y sus recursos asociados (direcciones IP, registros DNS, etc.), lo que es útil para pruebas de penetración, auditorías de seguridad y tareas de recolección de información.

## Características

- **Reconocimiento de DNS**: Realiza consultas DNS para obtener información sobre el dominio, incluyendo registros A, AAAA, MX, NS, SOA, TXT, CAA, entre otros.
- **Obtención de direcciones IP**: Utiliza herramientas para realizar resoluciones inversas de IP y obtener direcciones asociadas.
- **Whois**: Extrae información WHOIS para obtener detalles sobre la propiedad del dominio y la información de contacto.
- **Verificación de subdominios**: Detecta subdominios asociados al dominio objetivo.
- **Integración de herramientas**: Utiliza herramientas populares como `whois`, `dig`, `ctfr`, `httpx`, entre otras, para obtener resultados detallados.

## Requisitos

- **Herramientas necesarias**:
    - whois
    - dig
    - ctfr
    - httpx
    - dnsx
    - markmap
    - katana
    - subfinder
    - gau
    - cero
## Uso

### Ejecución básica

El script toma como entrada un dominio y realiza varias tareas de reconocimiento, mostrando la información de salida por consola.

```bash
./main.sh <domain>
```

Además, se incluye un script de scrapping en Python para la recolección de información sobre ASN (Autonomous System Numbers).

## Herramientas adicionales necesarias para el scrapping

1. Python 3: Asegúrate de tener instalado Python 3 en tu sistema.
2. Crea un entorno virtual con `python -m venv .venv`
3. Activa el entorno virtual con `source .venv/bin/activate`
4. Baja las dependencias con pip install requirements.txt
5. Lanza el script `./scrapping-asn.sh <domain.txt>`


