// Use this data provider to expose an access token for communicating with the GKE cluster.
data "google_client_config" "client" {}


/***********
  Providers
***********/

provider "google" {
  /* Used with credentials JSON file of service account key
    If not use it don't forget run "gcloud auth application-default login" 
    command to get default credentials 
  */
  // credentials = file(var.global_credentials_file)
  project = var.global_project
  region = var.global_region
}

// Values for "helm" provider takes from "gke" module
provider "helm" {
  kubernetes {
    host = module.gke.endpoint
    token = data.google_client_config.client.access_token
    cluster_ca_certificate = module.gke.cluster_ca_certificate
    load_config_file = false
  }
}

/***********
  Modules
***********/

module "gke-sa" {
  source = "./modules/gke-sa"

  sa_name = "gkeserviceaccount"
  sa_description = "GKE Service Account"
}

module "vpc" {
  source = "./modules/vpc"

  cluster_network = "gke-vpc-1"
  cluster_subnetwork = "gke-vpc-1-s01"
  cluster_cidr = "10.0.20.0/24"

  ip_range_pods = "gke-vpc-1-s01-pods"
  pods_cidr = "10.0.21.0/24"

  ip_range_services = "gke-vpc-02-s01-srvs"
  services_cidr = "10.0.22.0/24"

}

module "gke" {
  source = "./modules/gke"

  /**********************
    Cluster settings
  ***********************/

  cluster_name = "test-gke-cluster"
  // Set to "true" for regional cluster
  cluster_regional = false
  cluster_region = "us-central1"
  // Set two or more zones to create multizone cluster
  cluster_zones = ["us-central1-a","us-central1-b"]

  cluster_network = module.vpc.cluster_network
  cluster_subnetwork = module.vpc.cluster_subnetwork

  ip_range_pods = module.vpc.ip_range_pods
  ip_range_services = module.vpc.ip_range_services


  default_max_pods_per_node = 50

  /*
  cluster_resource_labels = {
    high_perf = true
  }
  */
  node_pools = [
    {
      name = "n1-node-pool"
      machine_type = "n1-standard-1"
      min_count = 1
      max_count = 10
      local_ssd_count = 0
      disk_size_gb = 10
      disk_type = "pd-standard"
      image_type = "COS"
      auto_repair = true
      auto_upgrade = true
      service_account = module.gke-sa.sa_email
      preemptible = false
      initial_node_count = 1
      max_pods_per_node = 20
    },
  ]

  /* Uncomment and set node pool labels
  node_pools_labels = {
    all = {
      n1-type-nodes = true
    }

    n1-node-pool = {
      team = "dev"
    }
    n2-node-pool = {
      team = "prod"
    }

    default-node-pool = {
      default-node-pool = true
    }
  }
  */

  node_pools_metadata = {
    all = {}

    default-node-pool = {
      node-pool-metadata-custom-value = "my-node-pool"
    }
  }

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/devstorage.full_control",
    ]

    default-node-pool = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
  
}

