#!/usr/bin/env python3
import os, subprocess, time, json, argparse

def check_env_vars(args=['VES_API_URL', 'VES_P12', 'VES_P12_PASSWORD']):
    for var in args:
        if var in os.environ:
            continue
        else:
            print('missing required ENV var {}.'.format(var))
            os._exit(1)

def find_url(type, name, namespace=''):
    res_map={
        'ns': '{0}/web/namespaces/{1}'.format(os.environ.get('VES_API_URL'), name),
        'vk8s': '{0}/config/namespaces/{1}/virtual_k8ss/{2}'.format(os.environ.get('VES_API_URL'), namespace, name)
    }
    return res_map[type]

def resource_present(url: str):
    cert_str = os.environ.get('VES_P12') + ":" + os.environ.get('VES_P12_PASSWORD')
    try:
        res = subprocess.run(
            ['curl', '--cert-type', 'P12', '--cert', cert_str,
            '-s', '-o', '/dev/null',
            '-w', '%{http_code}', url],
            text=True,
            stdout=subprocess.PIPE,
            check=True
        )
        if res.stdout == '200':
            return True
        else:
            return False
    except Exception as e:
        print("err checking presence: {}.".format(e))
        os._exit(1)

def resource_initialized(url: str):
    cert_str = os.environ.get('VES_P12') + ":" + os.environ.get('VES_P12_PASSWORD')
    try:
        res = subprocess.run(
            ['curl', '--cert-type', 'P12', '--cert', cert_str, '-s', url],
            text=True,
            stdout=subprocess.PIPE,
            check=True
        )
        try:
            j_res = json.loads(res.stdout)
            if len(j_res['system_metadata']['initializers']['pending']) > 0:
                return False
            else:
                return True
        except:
            return False
    except Exception as e:
        print("err checking initialization: {}.".format(e))
        os._exit(1)

def resource_ready(type: str, name: str, namespace: str, timeout: int, retry: int=10):
    url = find_url(type, name, namespace)
    current = time.time()
    expiry = current + timeout
    while current < expiry:
        present = resource_present(url)
        initialized = resource_initialized(url)
        if present and initialized:
            return
        time.sleep(retry)
        current = time.time()
    print('timeout reached.')
    os._exit(1)
  
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
        default='',
        required=False
    )
    ap.add_argument(
        '--timeout',
        help='timeout for readiness',
        default=180,
        required=False
    )
    args = ap.parse_args()
    check_env_vars()
    resource_ready(args.type, args.name, args.ns, int(args.timeout))
    os._exit(0)

if __name__ == '__main__':
    main()