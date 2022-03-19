resource "kubernetes_config_map_v1" "app_kubecfg" {
  metadata {
    name = "app-kubecfg"
    namespace = var.namespace
    annotations = {
      "ves.io/virtual-sites" = "${var.namespace}/${var.vsite}"
    }
  }
  data = {
    kubeconfig = base64decode(var.app_kubecfg)
  }
}

resource "kubectl_manifest" "podcleaner_cron" {
    yaml_body = <<YAML
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  annotations:
    ves.io/virtual-sites: ${var.namespace}/${var.vsite}
  name: podcleaner
  namespace: ${var.namespace}
spec:
  concurrencyPolicy: Allow
  failedJobsHistoryLimit: 1
  jobTemplate:
    spec:
      backoffLimit: 0
      completions: 1
      manualSelector: false
      parallelism: 1
      template:
        metadata:
          annotations:
            ves.io/virtual-sites: ${var.namespace}/${var.vsite}
            ves.io/workload-flavor: tiny
        spec:
          containers:
          - env:
            - name: NAMESPACE
              value: ${var.app_namespace}
            - name: KUBE_PATH
              value: /tmp/kubeconfig
            image: ${var.regsitry_server}/cleaner
            imagePullPolicy: Always
            name: cleaner
            resources: {}
            terminationMessagePath: /dev/termination-log
            terminationMessagePolicy: File
            volumeMounts:
            - mountPath: /tmp
              mountPropagation: None
              name: kubecfg
              readOnly: true
          dnsPolicy: ClusterFirst
          imagePullSecrets:
          - name: f5demos-registry-secret
          restartPolicy: OnFailure
          volumes:
          - configMap:
              items:
              - key: kubeconfig
                path: kubeconfig
              name: app-kubecfg
            name: kubecfg
  schedule: '* * * * *'
  successfulJobsHistoryLimit: 3
YAML
}
