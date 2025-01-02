from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
from selenium import webdriver
import argparse
from urllib.parse import urlparse
import re

chrome_options = Options()
chrome_options.add_argument("--headless")
chrome_options.add_argument("--no-sandbox")
chrome_options.add_argument("--disable-dev-shm-usage")

driver = webdriver.Chrome(options=chrome_options)

# Configuración de argparse para recibir el dominio como parámetro
parser = argparse.ArgumentParser(description="Consulta información de IP asociada a un dominio.")
parser.add_argument("-d", "--domain", required=True, help="Dominio a buscar")
args = parser.parse_args()


# Función para limpiar la URL y obtener solo el nombre del dominio principal
def extract_domain_name(url):
    parsed_url = urlparse(url)
    hostname = parsed_url.hostname if parsed_url.hostname else url
    # Elimina prefijos y extensiones comunes
    domain_name = re.sub(r"^(www\.)?|(\..*)", "", hostname)
    return domain_name

domain = extract_domain_name(args.domain)

try:
    driver.get("https://hackertarget.com/as-ip-lookup/")
    
    # Busca el campo de entrada y envía la consulta
    search = driver.find_element(By.NAME, "theinput")  # Asegúrate de que este nombre sea correcto
    search.send_keys(domain)
    search.submit()
    
    # Espera hasta que el elemento con ID "myTable" sea visible
    element = WebDriverWait(driver, 20).until(
        EC.visibility_of_element_located((By.ID, "myTable_wrapper"))
    )
    print(element.text)
    
except Exception as e:
    print("Error:", e)

finally:
    driver.quit()
