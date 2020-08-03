## Module for deploying single zone Google Kubernetes cluster

## Input variables:
- `cluster_name` - GKE cluster name.
- `cluster_description` - GKE cluster description.
- `cluster_regional` - Whether is a regional cluster (zonal cluster if set false. WARNING: changing this after cluster creation is destructive!).
- `cluster_region` - The region to host the cluster in (optional if zonal cluster / required if regional).
- `cluster_zones` - The zones to host the cluster in (required)
- `cluster_network` - The VPC network to host the cluster in.
- `cluster_subnetwork` - The subnetwork to host the cluster in.
- `ip_range_pods` - The name of the secondary subnet ip range to use for pods.
- `ip_range_services` - The name of the secondary subnet range to use for services.
- `basic_auth_username` - Username for basic authentication on kubernetes cluster. If empty - basic authentication disabled.
- `basic_auth_password` - Password for basic authentication on kubernetes cluster. If empty - basic authentication disabled.
- `default_max_pods_per_node` - The maximum number of pods to schedule per node.
- `node_pools` - List of maps containing node pools.
- `node_pools_oauth_scopes` - Map of lists containing node oauth scopes by node-pool name.
- `node_pools_labels` - Map of maps containing node labels by node-pool name.
- `node_pools_metadata` - Map of maps containing node metadata by node-pool name.
- `disable_legacy_metadata_endpoints` - Disable the /0.1/ and /v1beta1/ metadata server endpoints on the node. Changing this value will cause all node pools to be recreated.
- `logging_service` - The logging service that the cluster should write logs to. Available options include logging.googleapis.com, logging.googleapis.com/kubernetes (beta), and none.
- `monitoring_service` - The monitoring service that the cluster should write metrics to. Automatically send metrics from pods in the cluster to the Google Cloud Monitoring API. VM metrics will be collected by Google Compute Engine regardless of this setting Available options include monitoring.googleapis.com, monitoring.googleapis.com/kubernetes (beta) and none.
- `cluster_resource_labels` - The GCE resource labels (a map of key/value pairs) to be applied to the cluster.

## Output variables:
- `name` - The name of the cluster master.
- `master_version` - The Kubernetes master version.
- `cluster_ca_certificate` - The public certificate that is the root of trust for the cluster.
- `enpoint` - Cluster endpoint.

