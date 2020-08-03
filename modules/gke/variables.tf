variable "cluster_name" {
    description = "GKE cluster name."
    type = string
    default = "default-gke-cluster"
}

variable "cluster_description" {
    description = "GKE cluster description."
    type = string
    default = "default-gke-cluster description"
}

variable "cluster_regional" {
  type = bool
  description = "Whether is a regional cluster (zonal cluster if set false. WARNING: changing this after cluster creation is destructive!)."
  default = true
}

variable "cluster_region" {
  type = string
  description = "The region to host the cluster in (optional if zonal cluster / required if regional)."
  default = null
}

variable "cluster_zones" {
  type = list(string)
  description = "The zones to host the cluster in (required)"
  default = []
}

variable "basic_auth_username" {
    description = "Username for basic authentication on kubernetes cluster. If empty - basic authentication disabled."
    type = string
    default = null
}

variable "basic_auth_password" {
    description = "Password for basic authentication on kubernetes cluster. If empty - basic authentication disabled."
    type = string
    default = null
}

variable "default_max_pods_per_node" {
  description = "The maximum number of pods to schedule per node."
  default = 110
}

variable "node_pools" {
  type = list(map(string))
  description = "List of maps containing node pools."

  default = [
    {
      name = "default-node-pool"
    },
  ]
}

variable "node_pools_labels" {
  type = map(map(string))
  description = "Map of maps containing node labels by node-pool name."

  default = {
    all = {}
    default-node-pool = {}
  }
}

variable "node_pools_metadata" {
  type = map(map(string))
  description = "Map of maps containing node metadata by node-pool name."

  default = {
    all = {}
    default-node-pool = {}
  }
}

variable "node_pools_oauth_scopes" {
  type = map(list(string))
  description = "Map of lists containing node oauth scopes by node-pool name."

  default = {
    all = ["https://www.googleapis.com/auth/cloud-platform"]
    default-node-pool = []
  }
}

variable "disable_legacy_metadata_endpoints" {
  type = bool
  description = "Disable the /0.1/ and /v1beta1/ metadata server endpoints on the node. Changing this value will cause all node pools to be recreated."
  default = true
}

variable "logging_service" {
  type = string
  description = "The logging service that the cluster should write logs to. Available options include logging.googleapis.com, logging.googleapis.com/kubernetes (beta), and none."
  default = "logging.googleapis.com/kubernetes"
}

variable "monitoring_service" {
  type = string
  description = "The monitoring service that the cluster should write metrics to. Automatically send metrics from pods in the cluster to the Google Cloud Monitoring API. VM metrics will be collected by Google Compute Engine regardless of this setting Available options include monitoring.googleapis.com, monitoring.googleapis.com/kubernetes (beta) and none."
  default = "monitoring.googleapis.com/kubernetes"
}

variable "cluster_resource_labels" {
  type = map(string)
  description = "The GCE resource labels (a map of key/value pairs) to be applied to the cluster."
  default = {}
}

variable "cluster_network" {
  type = string
  description = "The VPC network to host the cluster in."
}

variable "cluster_subnetwork" {
  type = string
  description = "The subnetwork to host the cluster in."
}

variable "ip_range_pods" {
  type = string
  description = "The name of the secondary subnet ip range to use for pods."
}

variable "ip_range_services" {
  type = string
  description = "The name of the secondary subnet range to use for services."
}
