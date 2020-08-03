output "name" {
  description = "The name of the cluster master. This output is used for interpolation with node pools, other modules."
  value = google_container_cluster.cluster.name
}

output "master_version" {
  description = "The Kubernetes master version."
  value = google_container_cluster.cluster.master_version
}

// The following outputs allow authentication and connectivity to the GKE Cluster.
/*
output "client_certificate" {
  description = "Public certificate used by clients to authenticate to the cluster endpoint."
  value = base64decode(google_container_cluster.cluster.master_auth[0].client_certificate)
}

output "client_key" {
  description = "Private key used by clients to authenticate to the cluster endpoint."
  value = base64decode(google_container_cluster.cluster.master_auth[0].client_key)
}
*/
output "cluster_ca_certificate" {
  description = "The public certificate that is the root of trust for the cluster."
  value = base64decode(google_container_cluster.cluster.master_auth[0].cluster_ca_certificate)
}

output "endpoint" {
  sensitive = true
  description = "Cluster endpoint."
  value = google_container_cluster.cluster.endpoint
  depends_on = [
    /* Nominally, the endpoint is populated as soon as it is known to Terraform.
    * However, the cluster may not be in a usable state yet.  Therefore any
    * resources dependent on the cluster being up will fail to deploy.  With
    * this explicit dependency, dependent resources can wait for the cluster
    * to be up.
    */
    google_container_cluster.primary,
    google_container_node_pool.pools,
  ]
}

