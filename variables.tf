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

variable "app_namespace" {
  description = "the kubernetes namespace where the lingua-greeter demo application will be deployed"
  default     = "demo-apps"
}

variable "app_ksa" {
  description = "the kubernetes service account that will be used to run the lingua-greeter deployment"
  default     = "lingua-greeter"
}

variable "app_use_workload_identity" {
  description = "Flag to enable/disable application(pod) from using Workload Identity"
  default     = false
  type        = bool
}

variable "install_harness_delegate" {
  description = "Flag to install Harness Delegate"
  default     = true
  type        = bool
}

variable "harness_account_id" {
  description = "Harness Account Id to use while installing the delegate"
  type        = string
  sensitive   = true
}

variable "harness_delegate_token" {
  description = "Harness Delegate token"
  type        = string
  sensitive   = true
}

variable "harness_delegate_name" {
  description = "The Harness Delegate name"
  type        = string
  default     = "harness-delegate"
}

variable "harness_delegate_namespace" {
  description = "The Harness Delegate Kubernetes namespace"
  type        = string
  default     = "harness-delegate-ng"
}

variable "harness_manager_endpoint" {
  # https://developer.harness.io/tutorials/platform/install-delegate/
  # use one from above
  description = "The Harness SaaS manager endpoint to use"
  type        = string
}

variable "harness_delegate_image" {
  description = "The Harness delegate image to use"
  type        = string
  default     = "harness/delegate:23.02.78306"
}

variable "harness_delegate_replicas" {
  description = "The Harness delegate kubernetes replica count"
  default     = 1
  type        = number
}

variable "builder_namespace" {
  description = "the namespace where all Harness builder pods will be run"
  default     = "default"
}

variable "builder_ksa" {
  description = "the kubernetes service account that will be used to run the Harness delegate builder pods, which is enabled with Workload Identity"
  default     = "harness-builder"
}
