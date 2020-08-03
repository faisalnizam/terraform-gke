output "cluster_network" {
  description = ""
  value = google_compute_network.gke_vpc.name
}

output "cluster_subnetwork" {
  description = ""
  value = google_compute_subnetwork.vpc_gke_subnetwork.name
}

output "ip_range_pods" {
  description = ""
  value = var.ip_range_pods
}

output "ip_range_services" {
  description = ""
  value = var.ip_range_services
}