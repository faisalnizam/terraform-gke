variable "global_project" {
    description = "Google cloud platform project."
    type = string
    default = "tftest1c"
}

variable "global_credentials_file" {
    description = "JSON file with service account authentication credentials."
    type = string
    default = "/Users/apple/tftest1c.json"
}

variable "global_region" {
    description = "GCP region in which to perform operations."
    type = string
    default = "us-central1"
}
