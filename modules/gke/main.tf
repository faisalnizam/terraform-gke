/************************************************
  Local variables
  A local value assigns a name to an expression, 
  allowing it to be used multiple times within a 
  module without repeating it.
*************************************************/
locals {
  // Create list of node pool names: toset converts its argument to a set value
  node_pool_names = [for np in toset(var.node_pools) : np.name]
  // zipmap constructs a map from a list of keys and a corresponding list of values
  node_pools = zipmap(local.node_pool_names, tolist(toset(var.node_pools)))

  // if var.regional = true -> then take var.region value -> else take first element of var.zones[0]
  cluster_location = var.cluster_regional ? var.cluster_region : var.cluster_zones[0]
	// if var.regional = true -> then take var.region value -> else form region name from first zone name
  cluster_region = var.cluster_regional ? var.cluster_region : join("-", slice(split("-", var.cluster_zones[0]), 0, 2))
  // for regional cluster - use var.zones if provided, use available otherwise, for zonal cluster use var.zones with first element extracted
  // compact takes a list of strings and returns a new list with any empty string elements removed
  node_locations = var.cluster_regional ? compact(var.cluster_zones) : slice(var.cluster_zones, 1, length(var.cluster_zones))  

  /*
    merge takes an arbitrary number of maps and returns a single map that contains 
    a merged set of elements from all of the maps.
  */
  node_pools_labels = merge(
    { all = {} },
    { default-node-pool = {} },
    zipmap(
      [for node_pool in var.node_pools : node_pool["name"]],
      [for node_pool in var.node_pools : {}]
    ),
    var.node_pools_labels
  )

  node_pools_metadata = merge(
    { all = {} },
    { default-node-pool = {} },
    zipmap(
      [for node_pool in var.node_pools : node_pool["name"]],
      [for node_pool in var.node_pools : {}]
    ),
    var.node_pools_metadata
  )

  node_pools_oauth_scopes = merge(
    { all = ["https://www.googleapis.com/auth/cloud-platform"] },
    { default-node-pool = [] },
    zipmap(
      [for node_pool in var.node_pools : node_pool["name"]],
      [for node_pool in var.node_pools : []]
    ),
    var.node_pools_oauth_scopes
  )

}

resource "google_container_cluster" "cluster" {
  name = var.cluster_name
  description = var.cluster_description
  location = local.cluster_location
  node_locations = local.node_locations
  
  network = var.cluster_network
  subnetwork = var.cluster_subnetwork

  ip_allocation_policy {
    cluster_secondary_range_name = var.ip_range_pods
    services_secondary_range_name = var.ip_range_services
  }

  resource_labels = var.cluster_resource_labels
  remove_default_node_pool = true
  initial_node_count = 1
  default_max_pods_per_node = var.default_max_pods_per_node

  logging_service = var.logging_service
  monitoring_service = var.monitoring_service


  master_auth {
    // If this block is provided and both username and password are empty, basic authentication will be disabled
    username = var.basic_auth_username
    password = var.basic_auth_password

    /* Whether client certificate authorization is enabled for this cluster
     Issues a client certificate to authenticate to the cluster endpoint. 
     To maximize the security of your cluster, leave this option disabled. 
     Client certificates don't automatically rotate and aren't easily revocable. 
     WARNING: changing this after cluster creation is destructive! */
    client_certificate_config {
      issue_client_certificate = false
    }
  }

}

resource "google_container_node_pool" "pools" {
  cluster = google_container_cluster.cluster.name
  location = local.cluster_location

  // for_each: Multiple Resource Instances Defined By a Map, or Set of Strings 
  for_each = local.node_pools

  /*
   In resource blocks where for_each is set, an additional each object is available in expressions, 
    so you can modify the configuration of each instance. 
    each.key, each.value
  */
  name = each.key
  
  /*
    lookup retrieves the value of a single element from a map, given its key
    If the given key does not exist, a the given default value is returned instead.
      lookup(map, key, default)
    A conditional expression uses the value of a bool expression to select one of two values.
    The syntax of a conditional expression is as follows:
      condition ? true_val : false_val

    If in pool settings "autoscaling" is not set or true, then take "initial_node_count" or "min_count" if 
    "initial_node_count" not set. If "autoscaling" false then "initial_node_count" is null

    If you set an argument of a resource or module to null, Terraform behaves as though you had completely omitted it
  */
  initial_node_count = lookup(each.value, "autoscaling", true) ? lookup(
    each.value,
    "initial_node_count",
    lookup(each.value, "min_count", 1)
  ) : null

  max_pods_per_node = lookup(each.value, "max_pods_per_node", null)

  /*
    A dynamic block acts much like a for expression, but produces nested blocks instead of a complex typed value
    Next block produces the following:
      autoscaling {
        min_node_count = 
        max_node_count = 
      }
    if "autoscaling" in node pool settings is true
  */
  dynamic "autoscaling" {
    for_each = lookup(each.value, "autoscaling", true) ? [each.value] : []
    content {
      min_node_count = lookup(autoscaling.value, "min_count", 1)
      max_node_count = lookup(autoscaling.value, "max_count", 100)
    }
  }

  management {
    auto_repair = lookup(each.value, "auto_repair", true)
    auto_upgrade = lookup(each.value, "auto_upgrade", null)
  }

  node_config {
    image_type = lookup(each.value, "image_type", "COS")
    machine_type = lookup(each.value, "machine_type", "n1-standard-1")
    
    local_ssd_count = lookup(each.value, "local_ssd_count", 0)
    disk_size_gb = lookup(each.value, "disk_size_gb", 100)
    disk_type = lookup(each.value, "disk_type", "pd-standard")

    service_account = lookup(
      each.value,
      "service_account",
      null,
    )

    preemptible = lookup(each.value, "preemptible", false)

    // List of the type and count of accelerator cards attached to the instance. 
    guest_accelerator = [
      for guest_accelerator in lookup(each.value, "accelerator_count", 0) > 0 ? [{
        type = lookup(each.value, "accelerator_type", "")
        count = lookup(each.value, "accelerator_count", 0)
        }] : [] : {
        type = guest_accelerator["type"]
        count = guest_accelerator["count"]
      }
    ]

    labels = merge(
      lookup(lookup(local.node_pools_labels, "default_values", {}), "cluster_name", true) ? { "cluster_name" = var.cluster_name } : {},
      lookup(lookup(local.node_pools_labels, "default_values", {}), "node_pool", true) ? { "node_pool" = each.value["name"] } : {},
      local.node_pools_labels["all"],
      local.node_pools_labels[each.value["name"]],
    )

    metadata = merge(
      lookup(lookup(local.node_pools_metadata, "default_values", {}), "cluster_name", true) ? { "cluster_name" = var.cluster_name } : {},
      lookup(lookup(local.node_pools_metadata, "default_values", {}), "node_pool", true) ? { "node_pool" = each.value["name"] } : {},
      local.node_pools_metadata["all"],
      local.node_pools_metadata[each.value["name"]],
      {
        "disable-legacy-endpoints" = var.disable_legacy_metadata_endpoints
      },
    )

    oauth_scopes = concat(
      local.node_pools_oauth_scopes["all"],
      local.node_pools_oauth_scopes[each.value["name"]],
    )

  }
 
}



