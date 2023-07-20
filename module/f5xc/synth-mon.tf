/*
Synthetic monitors are not **yet** a supported resource in the provider.
*/
resource "null_resource" "synthetic_monitor_http" {
    count = var.enable_synthetic_monitors? 1 : 0
    triggers = {
        name    = format("%s-http", var.base)
        ns      = volterra_namespace.app_ns.name
        api_url = var.api_url
        p12     = format("creds/%s", var.api_p12_file)
        data = jsonencode(
            {
                "namespace" = volterra_namespace.app_ns.name
                "metadata" = {
                    "name" = format("%s-http", var.base)
                    "description" = "shop demo http monitor"
                }
                "spec" = {
                    "url" = format("https://%s", var.app_fqdn)
                    "interval_1_min" = {}
                    "head" = {}
                    "on_failure_count" = 1
                    "response_timeout" = 45
                    "source_critical_threshold" = 1
                    "external_sources" =  [
                        {"aws" = {"regions" = ["us-east-2", "us-west-1", "eu-north-1", "ap-east-1"]}}
                    ]
                    "response_codes" = ["2**"]
                    }
                }
            }
        )
    }
    provisioner "local-exec" {
        command = "./misc/f5xc_synth_mon.py --type http --ns ${self.triggers.ns} --data '${self.triggers.data}'"
        environment = {
            VES_API_URL = self.triggers.api_url
            VES_P12     = self.triggers.p12
        }
    }
    provisioner "local-exec" {
        when    = destroy
        command = "./misc/f5xc_synth_mon.py --type http --name ${self.triggers.name} --ns ${self.triggers.ns} --delete"
        environment = {
            VES_API_URL = self.triggers.api_url
            VES_P12     = self.triggers.p12
        }
    }
}

resource "null_resource" "synthetic_monitor_dns" {
    count = var.enable_synthetic_monitors? 1 : 0
    triggers = {
        name    = format("%s-dns", var.base)
        ns      = volterra_namespace.app_ns.name
        api_url = var.api_url
        p12     = format("creds/%s", var.api_p12_file)
        data = jsonencode(
        {
            "namespace" = volterra_namespace.app_ns.name
            "metadata" = {
                "name" = format("%s-dns", var.base)
                "description" = "shop demo dns monitor"
            }
            "spec" = {
                "domain" = var.app_fqdn
                "interval_1_min" = {}
                "record_type" = "A"
                "protocol" = "UDP"
                "on_failure_to_all" = {}
                "on_failure_count" = 1
                "lookup_timeout" = 30
                "source_critical_threshold" = 1
                "external_sources" =  [
                    {"aws" = {"regions" = ["us-east-2", "us-west-1", "eu-north-1", "ap-east-1"]}}
                ]
            }
        }
        )
    }

    provisioner "local-exec" {
        command = "./misc/f5xc_synth_mon.py --type dns --ns ${self.triggers.ns} --data '${self.triggers.data}'"
        environment = {
            VES_API_URL = self.triggers.api_url
            VES_P12     = self.triggers.p12
        }
    }
    provisioner "local-exec" {
        when    = destroy
        command = "./misc/f5xc_synth_mon.py --type dns --name ${self.triggers.name} --ns ${self.triggers.ns} --delete"
        environment = {
            VES_API_URL = self.triggers.api_url
            VES_P12     = self.triggers.p12
        }  
    }
}

