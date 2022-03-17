from kubernetes import client, config

def getClient():
    try:
        #placeholder for when we need to actually **do** something here
        config.load_kube_config()
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
            for container in pod.status.container_statuses:
                restarts = restarts + container.restart_count
            if restarts >= restartThreshold:#
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


client = getClient()
failed = getFailedPods(client, "demo-shop-stage")
misbehavin = getMisbehavinPods(client, "demo-shop-stage")
deletePods(client, failed, "demo-shop-stage")
deletePods(client, misbehavin, "demo-shop-stage")
