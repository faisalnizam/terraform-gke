variable "cluster_network" {
  type = string
  description = "The VPC network to host the cluster in."
}

variable "cluster_subnetwork" {
  type = string
  description = "The subnetwork to host the cluster in."
}

variable "cluster_cidr" {
  type = string
  description = "The subnetwork CIDR for cluster"
}

variable "ip_range_pods" {
  type = string
  description = "The name of the secondary subnet ip range to use for pods."
}

variable "pods_cidr" {
  type = string
  description = "CIDR range for pods"
}

variable "ip_range_services" {
  type = string
  description = "The name of the secondary subnet range to use for services."
}

variable "services_cidr" {
  type = string
  description = "CIDR range for services"
}