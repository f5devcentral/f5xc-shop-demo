import requests, argparse, os
from requests_pkcs12 import Pkcs12Adapter

def getAuthSession(p12_file: str, p12_pass: str) -> dict:
    try:
        s = requests.Session()
        s.mount('https://', Pkcs12Adapter(pkcs12_filename=p12_file, pkcs12_password=p12_pass))
        return s
    except Exception as e:
        raise e

def revokeCred(s: dict, api: str, credID: str, namespace: str='system') -> None:
    try:
        url = '{0}/web/namespaces/system/revoke/api_credentials'.format(api)
        payload = {
            'name': credID,
            'namespace': namespace
        }
        resp = s.post(url, json=payload)
        resp.raise_for_status()
    except Exception as e:
        raise e

def main():
    ap = argparse.ArgumentParser(
        prog='f5xc_cred_destroy',
        usage='%(prog)s.py [options]',
        description='clean up creds on destroy'
    )
    ap.add_argument(
        '--cred',
        help='cred to be revoked (full cred id)',
        required=True
    )
    ap.add_argument(
        '--p12',
        help='p12 cred file',
        default='../cred.p12'
        required=False
    )
    args = ap.parse_args()
    try:
        p12_pass = os.environ.get('VES_P12_PASSWORD')
        api_url = os.environ.get('VES_API_URL')
        s = getAuthSession(args.api, p12_pass)
        revokeCred(s, api_url, args.tenant, args.cred)
    except Exception as e:
        raise e

if __name__ == '__main__':
    main()