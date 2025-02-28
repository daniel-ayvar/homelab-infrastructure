output "kube_config" {
  value     = module.talos.kube_config.kubeconfig_raw
  sensitive = true
}

output "talos_config" {
  value     = module.talos.client_configuration.talos_config
  sensitive = true
}

output "machine_configs" {
  value     = module.talos.machine_config
  sensitive = true
}

output "kubernetes" {
  value = {
    auth = {
      host          = module.talos.kube_config.kubernetes_client_configuration.host
      client_key_b64 = module.talos.kube_config.kubernetes_client_configuration.client_key
      client_certificate_b64 = module.talos.kube_config.kubernetes_client_configuration.client_certificate
      cluster_ca_certificate_b64 = module.talos.kube_config.kubernetes_client_configuration.ca_certificate
    }

  }
  sensitive = true
}
