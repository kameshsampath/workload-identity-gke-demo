output "region" {
  value       = var.region
  description = "GCloud Region"
}

output "project_id" {
  value       = var.project_id
  description = "GCloud Project ID"
}

output "zone" {
  value       = local.google_zone
  description = "GCloud Zone"
}

output "kubernetes_cluster_name" {
  value       = google_container_cluster.primary.name
  description = "GKE Cluster Name"
}

output "kubernetes_cluster_host" {
  value       = google_container_cluster.primary.endpoint
  description = "GKE Cluster Host"
}

output "kubeconfig_path" {
  value       = abspath(local_file.kubeconfig.filename)
  description = "Kubeconfig file"
}

output "translator_service_account" {
  value       = google_service_account.translator_sa.email
  description = "The Google Service Account 'translator'"
}

output "ksa_patch" {
  value = templatefile("templates/sa.tfpl", {
    serviceAccountName : "${var.app_ksa}"
    serviceAccountNamespace : "${var.app_namespace}",
    googleServiceAccountEmail : "${google_service_account.translator_sa.email}"
  })
  description = "The Kubernetes Service Account patch"
}




