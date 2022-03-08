#!/usr/bin/env python3

import argparse, os, sys
from common import getAuthSession

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
        s = getAuthSession(args.p12, p12_pass)
        revokeCred(s, api_url, args.tenant, args.cred)
    except Exception as e:
        raise e

if __name__ == '__main__':
    main()