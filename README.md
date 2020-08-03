
## Root module to deploy GKE cluster with Helm charts.


### Module structure.
Root module consists of 3 modules which calls during deployment:
- `gke-sa` - module for creating service account for GKE cluster nodes.
- `gke` - module for deploying GKE clusters.
- `helm` - module for deploying Helm charts on GKE cluster.
Each module contains README.md file with short description.

#### Input variables
- `global_project` - Google cloud platform project.
- `global_credentials_file` - JSON file with service account authentication credentials.
- `global_region` - GCP region in which to perform operations.

#### Output variables
- `cluster_endpoint` - The IP address of the cluster master.
- `cluster_ca_certificate` - The public certificate that is the root of trust for the cluster.
- `chart_instance_name` - Name of chart instance.
- `chart_instance_status` - Status of chart deployment.

### Initial steps to set up your work environment on Linux (tested on CentOS 7) and start deployment.

1. Install gcloud (Google Cloud SDK).

    Instructions: https://cloud.google.com/sdk/docs/quickstart-linux
- `curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-299.0.0-linux-x86_64.tar.gz`
- `tar zxvf google-cloud-sdk-299.0.0-linux-x86_64.tar.gz google-cloud-sdk`
- `./google-cloud-sdk/install.sh`
- `gcloud init`
- `gcloud components update`
- `gcloud auth application-default login`

2. Install terraform.

    Instructions: https://learn.hashicorp.com/terraform/getting-started/install.html
- download package
- `yum install unzip`
- `unzip terraform_0.12.28_linux_amd64.zip`
- `mv ~/terraform /usr/local/bin/terraform`
- `terraform -help` 
    
3. Start deployment.
- `cd gcloud`
- `terraform init ./`
- `terraform plan ./`
- `terraform apply ./`


### Description of current example deployment.
In this example terraform deploys single zone cluster with two node pools.
As an example terraform deploys "Wordpress" helm chart with ingress enabled.

