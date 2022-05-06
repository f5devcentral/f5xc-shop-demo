import sys
sys.path.append('packages')

import requests
from requests_pkcs12 import Pkcs12Adapter

def getAuthSession(p12_file: str, p12_pass: str) -> dict:
    try:
        s = requests.Session()
        s.mount('https://', Pkcs12Adapter(pkcs12_filename=p12_file, pkcs12_password=p12_pass))
        return s
    except Exception as e:
        raise e
