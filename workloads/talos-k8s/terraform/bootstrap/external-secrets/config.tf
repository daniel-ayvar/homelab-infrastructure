resource "kubernetes_namespace" "external_secrets" {
  metadata {
    name = "external-secrets"
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  namespace  = kubernetes_namespace.external_secrets.metadata[0].name
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = "0.14.1"
}

resource "infisical_project" "k8s_secret_project" {
  name        = "Homelab Infrastructure K8s"
  slug        = "homelab-infrastructure-k8s"
  description = "This is a project of k8s secrets"
}

resource "random_string" "identity_name" {
  length           = 16
  special          = false
}

resource "infisical_identity" "universal_auth" {
  name   = random_string.identity_name.result
  role   = "member"
  org_id = var.infisical_workspace_id
}

resource "infisical_project_identity" "project_identity" {
  project_id  = infisical_project.k8s_secret_project.id
  identity_id = infisical_identity.universal_auth.id
  roles = [
    {
      role_slug = "admin"
    }
  ]
}

resource "infisical_identity_universal_auth" "universal_auth" {
  identity_id = infisical_identity.universal_auth.id
}

resource "infisical_identity_universal_auth_client_secret" "unverstal_auth_secret" {
  identity_id = infisical_identity_universal_auth.universal_auth.identity_id
  description = "Secrets client for homelab infrastructure k8s"
}

resource "kubernetes_secret" "infisical_auth" {
  metadata {
    name      = "infisical-auth"
    namespace = kubernetes_namespace.external_secrets.metadata[0].name
  }

  type = "Opaque"

  data = {
    clientId     = infisical_identity_universal_auth_client_secret.unverstal_auth_secret.client_id
    clientSecret = infisical_identity_universal_auth_client_secret.unverstal_auth_secret.client_secret
  }
}

resource "kubectl_manifest" "infisical" {
  # Depending on project_identity since role must be give project permissions or else it
  # will fail validation
  depends_on = [ helm_release.external_secrets, infisical_project_identity.project_identity ]

  yaml_body = <<YAML
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: infisical
spec:
  provider:
    infisical:
      auth:
        universalAuthCredentials:
          clientId:
            key: "clientId"
            namespace: ${kubernetes_namespace.external_secrets.metadata[0].name}
            name: ${kubernetes_secret.infisical_auth.metadata[0].name}
          clientSecret:
            key: "clientSecret"
            namespace: ${kubernetes_namespace.external_secrets.metadata[0].name}
            name: ${kubernetes_secret.infisical_auth.metadata[0].name}
      secretsScope:
        projectSlug: ${infisical_project.k8s_secret_project.slug}
        environmentSlug: "prod"
        secretsPath: "/"
        recursive: true
      hostAPI: "https://app.infisical.com"
YAML
}


