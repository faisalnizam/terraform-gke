resource "google_compute_network" "gke_vpc" {
  name = var.cluster_network
  auto_create_subnetworks = "false"
  routing_mode = "REGIONAL"
}

resource "google_compute_subnetwork" "vpc_gke_subnetwork" {
  name = var.cluster_subnetwork

  network = google_compute_network.gke_vpc.self_link

  ip_cidr_range = var.cluster_cidr

  secondary_ip_range {
    range_name = var.ip_range_pods
    ip_cidr_range = var.pods_cidr
  }

   secondary_ip_range {
    range_name = var.ip_range_services
    ip_cidr_range = var.services_cidr
  }

}
