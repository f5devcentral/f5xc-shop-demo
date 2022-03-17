from kubernetes import client, config
import os

def getClient(kubeconfig: str):
    try:
        config.load_kube_config(kubeconfig)
        v1 = client.CoreV1Api()
        return (v1)
    except Exception as e:
        raise e

def getFailedPods(client, namespace: str) -> list:
    try:
        states = ["Failed", "CrashLoopBackOff"]
        failed = []
        pods = client.list_namespaced_pod(namespace)
        for pod in pods.items:
            if pod.status.phase in states:
                failed.append(pod.metadata.name)
        return(failed)
    except Exception as e:
        raise e

def getMisbehavinPods(client, namespace: str, restartThreshold: int=5) -> list:
    try:
        misbehavin = []
        pods = client.list_namespaced_pod(namespace)
        for pod in pods.items:
            restarts = 0
            if pod.status.container_statuses:
                for container in pod.status.container_statuses:
                    restarts = restarts + container.restart_count
                if restarts >= restartThreshold:
                    misbehavin.append(pod.metadata.name)
        return(misbehavin)
    except Exception as e:
        raise e

def deletePods(client, podNames: list, namespace: str) -> None:
    try:
        for pod in podNames:
            client.delete_namespaced_pod(pod, namespace)
    except Exception as e:
        raise e

def main():
    try:
        namespace = os.environ.get('NAMESPACE')
        kubeconfPath = os.environ.get('KUBE_PATH')
        client = getClient(kubeconfPath)
        failed = getFailedPods(client, namespace)
        misbehavin = getMisbehavinPods(client, namespace)
        print(failed, misbehavin) #Do better logging here
        deletePods(client, failed, namespace)
        deletePods(client, misbehavin, namespace)
    except Exception as e:
        raise e

if __name__ == '__main__':
    main()