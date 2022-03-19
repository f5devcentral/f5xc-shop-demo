resource "kubectl_manifest" "loadgen_cron" {
    yaml_body = <<YAML
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: shop-traffic-gen
  annotations:
    ves.io/virtual-sites: ${var.namespace}/${var.vsite}
spec:
  schedule: "*/6 * * * *"
  successfulJobsHistoryLimit: 0
  failedJobsHistoryLimit: 1
  jobTemplate:
    spec:
      template:
        metadata:
          annotations:
            ves.io/workload-flavor: tiny
            ves.io/virtual-sites: ${var.namespace}/${var.vsite}
        spec:
          containers:
            - name: shop-traffic-gen
              image: ${var.registry_server}/loadgen
              env:
                - name: DURATION
                  value: 5m
                - name: TARGET_URL
                  value: ${var.target_url}
              resources: {}
              terminationMessagePath: /dev/termination-log
              terminationMessagePolicy: File
              imagePullPolicy: Always
          restartPolicy: OnFailure
          backoffLimit: 1
          terminationGracePeriodSeconds: 30
          dnsPolicy: ClusterFirst
          securityContext: {}
          imagePullSecrets:
            - name: f5demos-registry-secret
YAML
}