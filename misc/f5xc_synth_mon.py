#!/usr/bin/env python3
from logging import exception
import os, subprocess, json, argparse

def check_env_vars(args=['VES_API_URL', 'VES_P12', 'VES_P12_PASSWORD']):
    for var in args:
        if var in os.environ:
            continue
        else:
            print('missing required ENV var {}.'.format(var))
            os._exit(1)

def find_url(type: str, namespace: str):
    res_map={
        'http': '{0}/synthetic_monitor/namespaces/{1}/v1_http_monitors'.format(os.environ.get('VES_API_URL'), namespace),
        'dns': '{0}/synthetic_monitor/namespaces/{1}/v1_dns_monitors'.format(os.environ.get('VES_API_URL'), namespace)
    }
    return res_map[type]

def create_monitor(type: str, namespace: str, payload: str):
    url = find_url(type, namespace)
    cert_str = os.environ.get('VES_P12') + ":" + os.environ.get('VES_P12_PASSWORD')
    try:
        res = subprocess.run(
            ['curl', '--cert-type', 'P12', '--cert', cert_str, '-s', 
            '-X', 'POST', '-H', 'Content-Type: application/json', '-d', payload, url],
            text=True,
            stdout=subprocess.PIPE,
            check=False
        )
        json.loads(res.stdout)
        if res.stderr:
            raise Exception
    except Exception as e:
        print("err creating monitor: {}.".format(e))
        os._exit(1)

def delete_monitor(type: str, namespace: str, name: str):
    url = '{0}/{1}'.format(find_url(type, namespace), name)
    cert_str = os.environ.get('VES_P12') + ":" + os.environ.get('VES_P12_PASSWORD')
    try:
        res = subprocess.run(
            ['curl', '--cert-type', 'P12', '--cert', cert_str, '-s', 
            '-X', 'DELETE', url],
            text=True,
            stdout=subprocess.PIPE,
            check=True
        )
        if res.stderr:
            raise Exception
    except Exception as e:
        print("err deleting monitor: {}.".format(e))
        os._exit(1)
  
def main():
    ap = argparse.ArgumentParser(
        prog='f5xc_resource_ready',
        usage='%(prog)s.py [options]',
        description='create/destroy f5xc syntehtic monitors'
    )
    ap.add_argument(
        '--type',
        help='monitor type',
        choices=['dns', 'http'],
        required=True
    )
    ap.add_argument(
        '--ns',
        help='namespace',
        required=True
    )
    ap.add_argument(
        '--data',
        help='data/payload for monitor creation',
        required=False
    )
    ap.add_argument(
        '--delete',
        help='delete the monitor',
        action='store_true'
    )
    ap.add_argument(
        '--name',
        help='name of monitor',
        required=False
    )
    args = ap.parse_args()
    if not args.delete and args.data is None:
        ap.error("--data required.")
    if args.delete and args.name is None: 
        ap.error("--name required.")
    check_env_vars()
    if args.delete:
        delete_monitor(args.type, args.ns, args.name)
    else:
        create_monitor(args.type, args.ns, args.data)
    os._exit(0)

if __name__ == '__main__':
    main()