resource "google_service_account" "translator_sa" {
  account_id   = "translator"
  display_name = "Service Account that will be used to call Translate API"
}

resource "google_service_account_iam_binding" "admin-account-iam" {
  service_account_id = google_service_account.translator_sa.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[${var.app_namespace}/${var.app_ksa}]",
  ]
}

resource "google_project_iam_binding" "iam_binding_translate_users" {
  project = var.project_id
  role    = "roles/cloudtranslate.user"

  members = [
    google_service_account.translator_sa.member,
  ]
}

resource "local_file" "app_ksa" {
  content = templatefile("templates/sa.tfpl", {
    serviceAccountName : "${var.app_ksa}"
    serviceAccountNamespace : "${var.app_namespace}",
    googleServiceAccountEmail : "${google_service_account.translator_sa.email}"
  })
  filename             = "${path.module}/k8s/sa.yaml"
  file_permission      = 0600
  directory_permission = 0700
}
