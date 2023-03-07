# Using Workload Identity

A demo to show how to use [Workload Identity](https://cloud.google.com/kubernetes-engine/docs/concepts/workload-identity) with Harness Pipelines.

In this demo we will build Harness CI pipeline that will use GKE as its build infrastructure. As part of the build infrastructure on GKE we will deploy a Harness Delegate to run our CI pipelines on our GKE.

## Pre-requisites

- [Google Cloud Account](https://cloud.google.com)
  - With a Service Account with roles
    - `Kubernetes Engine Admin` - to create GKE cluster
    - `Service Account User`    - to use other needed service accounts
    - `Compute Network Admin`   - to create the VPC networks
  - Enable Cloud Translation API on the Google Cloud Project
- [Google Cloud SDK](https://cloud.google.com/sdk)
- [terraform](https://terraform.build)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [helm](https://helm.sh)(Optional)
- [kustomize](https://kustomize.io)(Optional)
- [direnv](https://direnv.net)(Optional)

## Download Sources

Clone the sources,

```shell
git clone https://github.com/harness-apps/workload-identity-gke-demo.git && cd "$(basename "$_" .git)"
export DEMO_HOME="$PWD"
```

## Environment Setup

### Variables

When working with Google Cloud the following environment variables helps in setting the right Google Cloud context like Service Account Key file, project etc., You can use [direnv](https://direnv.net) or set the following variables on your shell,

```shell
export GOOGLE_APPLICATION_CREDENTIALS="the google cloud service account key json file to use"
export CLOUDSDK_ACTIVE_CONFIG_NAME="the google cloud cli profile to use"
export GOOGLE_CLOUD_PROJECT="the google cloud project to use"
```

You can find more information about gcloud cli configurations at <https://cloud.google.com/sdk/docs/configurations>.

As you may need to override few terraform variables that you don't want to check in to VCS, add them to a file called `<name>.local.tfvars` and set the following environment variable to be picked up by terraform runs,

```shell
export TFVARS_FILE=<name>.local.tfvars
```

>**NOTE**: All `.local.tfvars` file are git ignored by this template.

Check the [Inputs](#inputs) section for all possible variables that are configurable.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_ksa"></a> [app\_ksa](#input\_app\_ksa) | the kubernetes service account that will be used to run the lingua-greeter deployment | `string` | `"lingua-greeter"` | no |
| <a name="input_app_namespace"></a> [app\_namespace](#input\_app\_namespace) | the kubernetes namespace where the lingua-greeter demo application will be deployed | `string` | `"demo-apps"` | no |
| <a name="input_app_use_workload_identity"></a> [app\_use\_workload\_identity](#input\_app\_use\_workload\_identity) | Flag to enable/disable application(pod) from using Workload Identity | `bool` | `false` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | the gke cluster name | `string` | `"my-demos"` | no |
| <a name="input_gke_num_nodes"></a> [gke\_num\_nodes](#input\_gke\_num\_nodes) | number of gke nodes | `number` | `2` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | the kubernetes versions of the GKE clusters | `string` | `"1.24."` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | the google cloud machine types for each cluster node | `string` | `"e2-standard-4"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | project id | `any` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | the region or zone where the cluster will be created | `string` | `"asia-south1"` | no |
| <a name="input_release_channel"></a> [release\_channel](#input\_release\_channel) | the GKE release channel to use | `string` | `"stable"` | no |

### Example
  
An example `my.local.tfvars` that will use a Google Cloud project **my-awesome-project**, create a two node GKE cluster named **wi-demo** in region **asia-south1** with Kubernetes version **1.24.** from **stable** release channel. The machine type of each cluster node will be **e2-standard-4**. The demo will be deployed in Kubernetes namespace **demo-apps**, will use **lingua-greeter** as the Kubernetes Service Account.

```hcl
project_id                 = "pratyakshika"
region                     = "asia-south1"
cluster_name               = "wi-demos"
kubernetes_version         = "1.24."
install_harness_delegate   = true
harness_account_id         = "REPLACE WITH YOUR HARNESS ACCOUNT ID"
harness_delegate_token     = "REPLACE WITH YOUR HARNESS DELEGATE TOKEN"
harness_delegate_name      = "wi-demos-delegate"
harness_delegate_namespace = "harness-delegate-ng"
harness_manager_endpoint   = "https://app.harness.io/gratis"
```

> **NOTE**: For rest of the section we assume that your tfvars file is called `my.local.tfvars`
>
> - `harness_manager_endpoint` value is can be found here <https://developer.harness.io/tutorials/platform/install-delegate/>, to right endpoint check for your **Harness Cluster Hosting Account** from the Harness Account Overview page.
> In the example above my **Harness Cluster Hosting Account** is **prod-2** and its endpoint is <https://app.harness.io/gratis>
> 

## Create Environment

We will use terraform to create a GKE cluster with `WorkloadIdentity` enabled for its nodes,

```shell
make apply
```

The terraform apply will create the following Google Cloud resources,

- A Kubernetes cluster on GKE
- A Google Cloud VPC that will be used with GKE

## Create Pipeline

```yaml
pipeline:
  name: REPLACE ME
  identifier: REPLACE ME
  projectIdentifier: REPLACE ME
  orgIdentifier: default
  tags: {}
  properties:
    ci:
      codebase:
        connectorRef: account.Github
        repoName: harness-apps/workload-identity-gke-demo
        build: <+input>
  stages:
    - stage:
        name: Build
        identifier: Build
        type: CI
        spec:
          cloneCodebase: true
          infrastructure:
            type: KubernetesDirect
            spec:
              connectorRef: widemos
              namespace: default
              serviceAccountName: harness-builder
              automountServiceAccountToken: true
              nodeSelector: {}
              os: Linux
          execution:
            steps:
              - step:
                  type: Run
                  name: Download Binaries
                  identifier: Download_Binaries
                  spec:
                    connectorRef: account.DockerHub
                    image: alpine
                    shell: Sh
                    command: |-
                      apk add -U curl 
                      curl -sSL https://github.com/GoogleCloudPlatform/docker-credential-gcr/releases/download/v2.1.6/docker-credential-gcr_linux_amd64-2.1.6.tar.gz | tar -zx
                      curl -sSL https://github.com/ko-build/ko/releases/download/v0.12.0/ko_0.12.0_Linux_x86_64.tar.gz | tar -zx

                      mkdir -p /tools
                      mv docker-credential-gcr  /tools
                      mv ko /tools
                      export PATH="$PATH:/tools"

                      docker-credential-gcr configure-docker --registries="asia-south1-docker.pkg.dev"
                    imagePullPolicy: IfNotPresent
                  description: Download ko and docker-credential-gcr binaries
              - step:
                  type: Run
                  name: ko build and push
                  identifier: ko_build_and_push
                  spec:
                    connectorRef: account.DockerHub
                    image: golang:1.19-alpine3.17
                    shell: Sh
                    command: |-
                      export PATH=$PATH:/tools
                      cd /harness/app
                      ko build --bare --tag latest .
                    envVariables:
                      KO_DOCKER_REPO: asia-south1-docker.pkg.dev/pratyakshika/demos/lingua-greeter
                    imagePullPolicy: IfNotPresent
                    resources:
                      limits:
                        memory: 4G
                        cpu: 2000m
                  description: build and push the application using ko
          sharedPaths:
            - /tools
            - /root/.docker
```

## License

[Apache License](./../LICENSE)
