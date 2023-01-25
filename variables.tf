variable "project_id" {
  description = "project id"
}

variable "region" {
  description = "the region or zone where the cluster will be created"
  default     = "asia-south1"
}

variable "cluster_name" {
  description = "the gke cluster name"
  default     = "my-demos"
}

variable "gke_num_nodes" {
  default     = 2
  description = "number of gke nodes"
}

# gcloud compute machine-types list
variable "machine_type" {
  description = "the google cloud machine types for each cluster node"
  # https://cloud.google.com/compute/docs/general-purpose-machines#e2_machine_types
  default = "e2-standard-4"
}

variable "kubernetes_version" {
  description = "the kubernetes versions of the GKE clusters"
  # kubernetes version to use, major.minor
  default = "1.24."
}

variable "release_channel" {
  description = "the GKE release channel to use"
  type        = string
  default     = "stable"
}

