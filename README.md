# Using Workload Identity

A demo to show how to use [Workload Identity](https://cloud.google.com/kubernetes-engine/docs/concepts/workload-identity) to call Google Cloud API. In this demo we will call the [Translate API](https://cloud.google.com/translate) from a GKE application(pod) using Workload Identity.

## Pre-requisites

- [Google Cloud Account](https://cloud.google.com)
- With a [Service Account](https://cloud.google.com/iam/docs/service-account-overview) with roles:
  - `Kubernetes Engine Admin` - to create GKE cluster
  - `Service Account` roles used to create/update/delete Service Account
    - *iam.serviceAccounts.actAs*
    - *iam.serviceAccounts.get*
    - *iam.serviceAccounts.create*
    - *iam.serviceAccounts.delete*
    - *iam.serviceAccounts.update*
    - *iam.serviceAccounts.get*
    - *iam.serviceAccounts.getIamPolicy*
    - *iam.serviceAccounts.setIamPolicy*
   Or simply you can add `Service Account Admin` and `Service Account User` roles
  - `Compute Network Admin`   - to create the VPC networks
- [Google Cloud SDK](https://cloud.google.com/sdk)
- [terraform](https://terraform.build)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Taskfile](https://taskfile.dev)

### Optional

- [kustomize](https://kustomize.io)(Optional)
- [direnv](https://direnv.net)(Optional)

## Download Sources

Clone the sources,

```shell
git clone https://github.com/kameshsampath/workload-identity-gke-demo.git && cd "$(basename "$_" .git)"
export DEMO_HOME="$PWD"
```

## Environment Setup

### Variables

When working with Google Cloud the following environment variables helps in setting the right Google Cloud context like Service Account Key file, project etc., You can use [direnv](https://direnv.net) or set the following variables on your shell,

```shell
export GOOGLE_APPLICATION_CREDENTIALS="the google cloud service account key json file to use"
export CLOUDSDK_ACTIVE_CONFIG_NAME="the google cloud cli profile to use"
export GOOGLE_CLOUD_PROJECT="the google cloud project to use"
export KUBECONFIG="$DEMO_HOME/.kube"
```

(e.g.)

```shell
export CLOUDSDK_ACTIVE_CONFIG_NAME=personal
export GOOGLE_APPLICATION_CREDENTIALS=~/.ssh/my-sa-key.json
export GOOGLE_CLOUD_PROJECT=my-awesome-project
export KUBECONFIG="$DEMO_HOME/.kube"
```

> **TIP** If you are using direnv you can then create file `.envrc.local` and add the environment variables. They can then be loaded using `direnv allow .`

You can find more information about gcloud cli configurations at <https://cloud.google.com/sdk/docs/configurations>.

As you may need to override few terraform variables that you don't want to check in to VCS, add them to a file called `.local.tfvars` and set the following environment variable to be picked up by terraform runs,

```shell
export TFVARS_FILE=.local.tfvars
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
  
An example `.local.tfvars` that will use a Google Cloud project **my-awesome-project**, create a two node GKE cluster named **wi-demo** in region **asia-south1** with Kubernetes version **1.24.** from **stable** release channel. The machine type of each cluster node will be **e2-standard-4**. The demo will be deployed in Kubernetes namespace **demo-apps**, will use **lingua-greeter** as the Kubernetes Service Account.

```hcl
app_ksa            = "lingua-greeter"
app_namespace      = "demo-apps"
cluster_name       = "wi-demo"
configure_app_workload_identity = false
gke_num_nodes      = 2
kubernetes_version = "1.24."
machine_type       = "e2-standard-4"
project_id         = "my-awesome-project"
region             = "asia-south1"
release_channel    = "stable"
```

> **NOTE**: For rest of the section we assume that your tfvars file is called `.local.tfvars`
>

## Application Overview

As part of the demo, let us deploy a Kubernetes application called `lingua-greeter`. The application exposes a REST API `/:lang` , that allows you to translate a text `Hello World!` into the language `:lang` using Google Translate client.

> **NOTE**: The `:lang` is the BCP 47 language code, <https://en.wikipedia.org/wiki/IETF_language_tag>.
>

## Create Environment

We will use terraform to create a GKE cluster with `WorkloadIdentity` enabled for its nodes,

```shell
task init
```

### Create GKE cluster

The terraform apply will creates a Kubernetes(GKE) Cluster,

```shell
task create_cluster
```

The terraform apply will create the following Google Cloud resources,

- A Kubernetes cluster on GKE
- A Google Cloud VPC that will be used with GKE
  
### Deploy Application

To see **Workload Identity** in action we will deploy the application in two parts,

- Without application(workload) enabled for **Workload Identity**
- With application(workload) enabled for **Workload Identity**

Create the namespace `demo-apps` to deploy the `lingua-greeter` application,

```shell
kubectl create ns demo-apps
```

Run the following command to deploy the application,

```shell
kubectl apply -n demo-apps -k $DEMO_HOME/app/config
```

Wait for application to be ready,

```shell
kubectl rollout status -n demo-apps deployment/lingua-greeter --timeout=60s
```

Get the application service LoadBalancer IP,

```shell
kubectl get svc -n demo-apps lingua-greeter
```

> **NOTE**: If the `EXTERNAL-IP` is `<pending>` then wait for the IP to be assigned. It will take few minutes for the `EXTERNAL-IP` to be assigned.
> You can use the following command to wait until `External-IP` is assigned,
>
>```shell
> while [ -z $(kubectl get svc -n demo-apps lingua-greeter -ojsonpath="{.status.loadBalancer.ingress[*].ip}") ]; do sleep .3; done;
>```

### Call Service

```shell
export SERVICE_IP=$(kubectl get svc -n demo-apps lingua-greeter -ojsonpath="{.status.loadBalancer.ingress[*].ip}")
```

Call the service to return the translation of `Hello World!` in [Tamil(ta)](https://en.wikipedia.org/wiki/Tamil_language),

```shell
curl "http://$SERVICE_IP/ta"
```

The service should fail with a message,

```text
{"message":"Internal Server Error"}
```

When you check the logs of the `lingua-greeter` pod, you should see a message like,

```text
time="2023-01-25T10:26:50Z" level=error msg="googleapi: Error 401: Request had invalid authentication credentials. Expected OAuth 2 access token, login cookie or other valid authentication credential. See https://developers.google.com/identity/sign-in/web/devconsole-project.\nMore details:\nReason: authError, Message: Invalid Credentials\n"
```

As it describes you don't have authentication credentials to call the API. All Google Cloud API requires `GOOGLE_APPLICATION_CREDENTIALS` to allow client to authenticate itself before calling the API. If you check the [deployment manifest](./../app/config/deployment.yaml) we dont have one configured.

### Configure Application to use Workload Identity

- [x] Create a Service Account(SA) that has permissions to call Google Translation API, in our demo we call that SA as `translator`
- [x] Add `translator` SA with role `roles/cloudtranslate.user`
- [x] Add an [IAM binding policy](https://cloud.google.com/iam/docs/reference/rest/v1/Policy) to `translator` SA, with the role `roles/iam.workloadIdentityUser` and a member `"serviceAccount:$GOOGLE_CLOUD_PROJECT.svc.id.goog[demo-apps/lingua-greeter]"` (default workload identity SA)

Edit your `my.local.tfvars` file and update the `app_use_workload_identity` to be `true`.Save the `my.local.tfvars` and run the following command to create the SA, role and IAM policy binding resources,

```shell
task deploy_app
```

The command ran earlier should also generate an updated `lingua-greeter` Kubernetes Service Account manifest `$DEMO_HOME/k8s/sa.yaml`, that is annotated to impersonate the `translator` Google SA,

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: lingua-greeter
  namespace: demo-apps
  annotations:
    iam.gke.io/gcp-service-account: "translator@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com"
```

Run the following command to update the Kubernetes SA `lingua-greeter` to use the Google IAM service Account using **Workload Identity mechanics**,

```shell
kubectl apply -n demo-apps -f "$DEMO_HOME/k8s/sa.yaml"
```

[Call the service](#call-service) again, the service should succeed with a response,

```json
{"text":"Hello World!","translation":"வணக்கம் உலகம்!","translationLanguage":"ta"}
```

> **NOTE**: Sometimes it may take few seconds for the pods to refresh the metadata, in such cases try to call the service after few seconds.
>

For more information check out [Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity).

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ksa_patch"></a> [ksa\_patch](#output\_ksa\_patch) | The Kubernetes Service Account patch |
| <a name="output_kubeconfig_path"></a> [kubeconfig\_path](#output\_kubeconfig\_path) | Kubeconfig file |
| <a name="output_kubernetes_cluster_host"></a> [kubernetes\_cluster\_host](#output\_kubernetes\_cluster\_host) | GKE Cluster Host |
| <a name="output_kubernetes_cluster_name"></a> [kubernetes\_cluster\_name](#output\_kubernetes\_cluster\_name) | GKE Cluster Name |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | GCloud Project ID |
| <a name="output_region"></a> [region](#output\_region) | GCloud Region |
| <a name="output_translator_service_account"></a> [translator\_service\_account](#output\_translator\_service\_account) | The Google Service Account 'translator' |
| <a name="output_zone"></a> [zone](#output\_zone) | GCloud Zone |

## License

[Apache License](./../LICENSE)
