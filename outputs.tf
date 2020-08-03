output "cluster_endpoint" {
  description = "The IP address of the cluster master."
  sensitive = true
  value = module.gke.endpoint
}

output "cluster_ca_certificate" {
  description = "The public certificate that is the root of trust for the cluster."
  sensitive = true
  value = module.gke.cluster_ca_certificate
}

/* output "chart_instance_status" {
  description = "Status of chart deployment."
  value = module.helm.chart_instance_status
}

output "chart_instance_name" {
  description = "Name of chart instance."
  value = module.helm.chart_instance_name
}*/
