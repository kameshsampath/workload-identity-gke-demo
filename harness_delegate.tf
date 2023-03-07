provider "helm" {
  kubernetes {
    config_path = "${path.module}/.kube/config"
  }
}

provider "kubernetes" {
  config_path = "${path.module}/.kube/config"
}

## enable Workload Identity to Harness Delegate SA

resource "google_service_account" "harness_delegate_sa" {
  count        = var.install_harness_delegate ? 1 : 0
  account_id   = "harness-delegate"
  display_name = "Google Service Account that will be used for Harness CI Workload Identity use cases"
}

resource "google_service_account_iam_binding" "harness_delegate_workload_identity_iam" {
  count              = var.install_harness_delegate ? 1 : 0
  service_account_id = google_service_account.harness_delegate_sa[0].name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[${var.harness_delegate_namespace}/${var.harness_delegate_name}-delegate]",
    "serviceAccount:${var.project_id}.svc.id.goog[${var.builder_namespace}/${var.builder_ksa}]",
  ]
}

resource "google_project_iam_binding" "iam_binding_gar_push_repo_admin" {
  count   = var.install_harness_delegate ? 1 : 0
  project = var.project_id
  role    = "roles/artifactregistry.createOnPushRepoAdmin"

  members = [
    google_service_account.harness_delegate_sa[0].member,
  ]
}

resource "helm_release" "harness_delegate" {
  count = var.install_harness_delegate ? 1 : 0

  depends_on = [
    google_container_cluster.primary,
    local_file.kubeconfig,
    google_service_account.harness_delegate_sa
  ]

  name             = "${var.harness_delegate_name}-release"
  repository       = "https://app.harness.io/storage/harness-download/delegate-helm-chart/"
  chart            = "harness-delegate-ng"
  namespace        = var.harness_delegate_namespace
  create_namespace = true

  set {
    name  = "upgrader.enabled"
    value = "false"
  }

  set_sensitive {
    name  = "accountId"
    value = var.harness_account_id
  }

  set_sensitive {
    name  = "delegateToken"
    value = var.harness_delegate_token
  }

  set {
    name  = "delegateName"
    value = var.harness_delegate_name
  }
  set {
    name  = "managerEndpoint"
    value = var.harness_manager_endpoint
  }
  set {
    name  = "delegateDockerImage"
    value = var.harness_delegate_image
  }
  set {
    name  = "replicas"
    value = var.harness_delegate_replicas
  }

  # Enables Workload Identity for the Delegate SA
  set {
    name  = "serviceAccount.annotations.iam\\.gke\\.io\\/gcp-service-account"
    value = google_service_account.harness_delegate_sa[0].email
  }
}

# The service account that needs to be configured with Harnes pipeline infra
resource "kubernetes_manifest" "builder_ksa" {
  depends_on = [
    google_container_cluster.primary
  ]
  count = var.install_harness_delegate ? 1 : 0
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "ServiceAccount"
    "metadata" = {
      "name"      = "${var.builder_ksa}"
      "namespace" = "${var.builder_namespace}"
      "annotations" = {
        "iam.gke.io/gcp-service-account" = "${google_service_account.harness_delegate_sa[0].email}"
      }
    }
  }
}
