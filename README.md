# GKE Terraform Template

A GitHub template that could be used to get started with [Google Kubernetes Engine(GKE)](https://cloud.google.com/kubernetes-engine) using [terraform](https://terraform.build).

## Pre-requisites

- [Google Cloud Account](https://cloud.google.com)
  - With a Service Account with roles to create GKE Clusters
- [Google Cloud SDK](https://cloud.google.com/sdk)
- [terraform](https://terraform.build)
- [helm](https://helm.sh)(Optional)
- [kustomize](https://kustomize.io)(Optional)
- [direnv](https://direnv.net)(Optional)

## Using this Template

On browser navigate to the repo <https://github.com/kameshsampath/gke-tf> and click **Use Template**, follow the wizard to create your repository based on the template.

Using [github cli](https://cli.github.com/)

```shell
gh repo create --public --description="My GKE Demos and Examples" --template https://github.com/kameshsampath/gke-tf my-gke-demos
gh repo clone my-gke-demos
```

## Environment Variables

When working with Google Cloud the following environment variables helps in setting the right Google Cloud context like Service Account Key file, project etc., You can use [direnv](https://direnv.net) or set the following variables on your shell,

```shell
export GOOGLE_APPLICATION_CREDENTIALS="the google cloud service account key json file to use"
export CLOUDSDK_ACTIVE_CONFIG_NAME="the google cloud cli profile to use"
```

You can find more information about gcloud cli configurations at <https://cloud.google.com/sdk/docs/configurations>.

As you may need to override few terraform variables that you don't want to check in to VCS, add them to a file called `<name>.local.tfvars` and set the following environment variable to be picked up by terraform runs,

```shell
export TFVARS_FILE=<name>.local.tfvars
```

>**NOTE**: All `.local.tfvars` file are git ignored by this template.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | the gke cluster name | `string` | `"my-demos"` | no |
| <a name="input_gke_num_nodes"></a> [gke\_num\_nodes](#input\_gke\_num\_nodes) | number of gke nodes | `number` | `2` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | the kubernetes versions of the GKE clusters | `string` | `"1.24."` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | the google cloud machine types for each cluster node | `string` | `"e2-standard-4"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | project id | `any` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | the region or zone where the cluster will be created | `string` | `"asia-south1"` | no |
| <a name="input_release_channel"></a> [release\_channel](#input\_release\_channel) | the GKE release channel to use | `string` | `"stable"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kubeconfig_path"></a> [kubeconfig\_path](#output\_kubeconfig\_path) | Kubeconfig file |
| <a name="output_kubernetes_cluster_host"></a> [kubernetes\_cluster\_host](#output\_kubernetes\_cluster\_host) | GKE Cluster Host |
| <a name="output_kubernetes_cluster_name"></a> [kubernetes\_cluster\_name](#output\_kubernetes\_cluster\_name) | GKE Cluster Name |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | GCloud Project ID |
| <a name="output_region"></a> [region](#output\_region) | GCloud Region |
| <a name="output_zone"></a> [zone](#output\_zone) | GCloud Zone |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 4.47.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.2.3 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.4.3 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.47.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 2.8.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.16.1 |
| <a name="requirement_local"></a> [local](#requirement\_local) | 2.2.3 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.4.3 |

## Resources

| Name | Type |
|------|------|
| [google_compute_network.vpc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_subnetwork.subnet](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_container_cluster.primary](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster) | resource |
| [google_container_node_pool.primary_nodes](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool) | resource |
| [local_file.kubeconfig](https://registry.terraform.io/providers/hashicorp/local/2.2.3/docs/resources/file) | resource |
| [random_shuffle.az](https://registry.terraform.io/providers/hashicorp/random/3.4.3/docs/resources/shuffle) | resource |
| [google_compute_zones.available](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |
| [google_container_engine_versions.supported](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/container_engine_versions) | data source |

## References

- <https://cloud.google.com/translate>

- <https://cloud.google.com/kubernetes-engine/docs/concepts/workload-identity>

## License

[Apache License](./../LICENSE)
