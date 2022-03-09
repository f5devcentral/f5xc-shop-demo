#!/usr/bin/env python3

import argparse, os, requests, backoff
from common import getAuthSession

def findEndpoint(api: str, resType: str, name: str, namespace: str):
    if resType == 'ns':
        url = '{0}/web/namespaces/{1}'.format(api, name)
    elif resType == 'vk8s':
        url = '{0}/config/namespaces/{1}/virtual_k8ss/{2}'.format(api, namespace, name)
    else:
        raise Exception('not a valid resource') #This should never happen
    return url 

@backoff.on_exception(backoff.expo,requests.exceptions.RequestException, max_time=60)
@backoff.on_predicate(
    backoff.constant,
    lambda resp: len(resp['system_metadata']['initializers']['pending']) > 0,
    interval=5,
    max_time=120
)
def isResourceReady(s: dict, api: str, resType: str, name: str, namespace: str='none') -> str:
    try:
        url = findEndpoint(api, resType, name, namespace)
        resp = s.get(url)
        resp.raise_for_status()
        return(resp.json())
    except Exception as e:
        raise e

def main():
    ap = argparse.ArgumentParser(
        prog='f5xc_resource_ready',
        usage='%(prog)s.py [options]',
        description='check if f5xc resource is ready to be used'
    )
    ap.add_argument(
        '--type',
        help='resource type',
        choices=['ns', 'vk8s'],
        required=True
    )
    ap.add_argument(
        '--name',
        help='name of resource',
        required=True
    )
    ap.add_argument(
        '--ns',
        help='namespace if applicable',
        default='system',
        required=False
    )
    args = ap.parse_args()
    try:
        p12_pass = os.environ.get('VES_P12_PASSWORD')
        p12 = os.environ.get('VES_P12')
        api_url = os.environ.get('VES_API_URL')
        s = getAuthSession(p12, p12_pass)
        isResourceReady(s, api_url, args.type, args.name, args.ns)
    except Exception as e:
        raise e

if __name__ == '__main__':
    main()