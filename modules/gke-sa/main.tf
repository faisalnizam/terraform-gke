resource "google_service_account" "service_account" {
  account_id = var.sa_name
  display_name = var.sa_description
}

locals {
  all_service_account_roles = concat(var.service_account_roles, [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer",
    "roles/storage.objectViewer",
    "roles/storage.admin",
  ])
}

resource "google_project_iam_member" "service_account-roles" {
  for_each = toset(local.all_service_account_roles)

  role = each.value
  member = "serviceAccount:${google_service_account.service_account.email}"
}
