## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.12 |

## Providers

| Name | Version |
|------|---------|
| google | n/a |
| google-beta | n/a |
| random | n/a |

## Modules

No Modules.

## Resources

| Name |
|------|
| [google-beta_google_container_cluster](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_container_cluster) |
| [google_client_config](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) |
| [google_container_node_pool](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool) |
| [google_project_iam_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) |
| [google_service_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) |
| [random_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_private\_images | Whether to create the IAM role for storage.objectViewer, required to access<br>GCR for private container images. | `bool` | `false` | no |
| authenticator\_security\_group | The name of the RBAC security group for use with Google security groups in<br>Kubernetes RBAC. Group name must be in format<br>gke-security-groups@yourdomain.com. | `string` | `""` | no |
| cluster\_name | The name of the cluster, unique within the project and zone. | `string` | n/a | yes |
| cluster\_secondary\_range\_name | The name of the secondary range to be used as for the cluster CIDR block.<br>The secondary range will be used for pod IP addresses. This must be an<br>existing secondary range associated with the cluster subnetwork. | `string` | n/a | yes |
| daily\_maintenance\_window\_start\_time | The start time of the 4 hour window for daily maintenance operations RFC3339<br>format HH:MM, where HH : [00-23] and MM : [00-59] GMT. | `string` | n/a | yes |
| enable\_shielded\_nodes | (Optional) Enable Shielded Nodes features on all nodes in this cluster. Defaults to false. | `string` | `"true"` | no |
| gcp\_location | The location (region or zone) in which the cluster master will be created,<br>as well as the default node location. If you specify a zone (such as<br>us-central1-a), the cluster will be a zonal cluster with a single cluster<br>master. If you specify a region (such as us-west1), the cluster will be a<br>regional cluster with multiple masters spread across zones in that region.<br>Node pools will also be created as regional or zonal, to match the cluster.<br>If a node pool is zonal it will have the specified number of nodes in that<br>zone. If a node pool is regional it will have the specified number of nodes<br>in each zone within that region. For more information see:<br>https://cloud.google.com/kubernetes-engine/docs/concepts/regional-clusters | `string` | n/a | yes |
| gcp\_project\_id | The ID of the project in which the resources belong. | `string` | n/a | yes |
| http\_load\_balancing\_disabled | The status of the HTTP (L7) load balancing controller addon, which makes it<br>easy to set up HTTP load balancers for services in a cluster. It is enabled<br>by default; set disabled = true to disable. | `bool` | `false` | no |
| identity\_namespace | The workload identity namespace to use with this cluster. Currently, the only<br>supported identity namespace is the project's default<br>'[project\_id].svc.id.goog'.<br>https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity | `string` | `""` | no |
| master\_authorized\_networks\_cidr\_blocks | Defines up to 20 external networks that can access Kubernetes master<br>through HTTPS. | `list(map(string))` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "display_name": "openbar-demo"<br>  }<br>]</pre> | no |
| master\_ipv4\_cidr\_block | The IP range in CIDR notation to use for the hosted master network. This<br>range will be used for assigning internal IP addresses to the master or set<br>of masters, as well as the ILB VIP. This range must not overlap with any<br>other ranges in use within the cluster's network. | `string` | `"172.16.0.0/28"` | no |
| min\_master\_version | The minimum version of the master. GKE will auto-update the master to new<br>versions, so this does not guarantee the current master version. Use the<br>read-only 'master\_version' field to obtain that. If unset, the cluster's<br>version will be set by GKE to the version of the most recent official release<br>(which is not necessarily the latest version). Most users will find the<br>'google\_container\_engine\_versions' data source useful - it indicates which<br>versions are available. If you intend to specify versions manually, the<br>docs describe the various acceptable formats for this field.<br><br>This can be a specific version such as '1.16.8-gke.N', a patch or minor version<br>such as '1.X', the latest available version with 'latest', or the default<br>version with '-'.<br><br>Creating or upgrading a cluster by specifying the version as latest does not<br>provide automatic upgrades.<br><br>This option is overriden if a 'release\_channel' is set.<br><br>https://cloud.google.com/kubernetes-engine/versioning-and-upgrades#specifying_cluster_version | `string` | `""` | no |
| node\_pools | The list of node pool configurations, each can include:<br><br>name - The name of the node pool, which will be suffixed with '-pool'.<br>Defaults to pool number in the Terraform list, starting from 1.<br><br>initial\_node\_count - The initial node count for the pool. Changing this will<br>force recreation of the resource. Defaults to 1.<br><br>autoscaling\_min\_node\_count - Minimum number of nodes in the NodePool. Must be<br>>=0 and <= max\_node\_count. Defaults to 2.<br><br>autoscaling\_max\_node\_count - Maximum number of nodes in the NodePool. Must be<br>>= min\_node\_count. Defaults to 3.<br><br>management\_auto\_repair - Whether the nodes will be automatically repaired.<br>Defaults to 'true'.<br><br>management\_auto\_upgrade - Whether the nodes will be automatically upgraded.<br>Defaults to 'true'.<br><br>version - The Kubernetes version for the nodes in this pool. Note that if this<br>field is set the 'management\_auto\_upgrade' will be overriden and set to 'false'.<br>This is to avoid both options fighting on what the node version should be. While<br>a fuzzy version can be specified, it's recommended that you specify explicit<br>versions as Terraform will see spurious diffs when fuzzy versions are used. See<br>the 'google\_container\_engine\_versions' data source's 'version\_prefix' field to<br>approximate fuzzy versions in a Terraform-compatible way.<br><br>node\_config\_machine\_type - The name of a Google Compute Engine machine type.<br>Defaults to n1-standard-1. To create a custom machine type, value should be<br>set as specified here:<br>https://cloud.google.com/compute/docs/reference/rest/v1/instances#machineType<br><br>node\_config\_disk\_type - Type of the disk attached to each node (e.g.<br>'pd-standard' or 'pd-ssd'). Defaults to 'pd-standard'<br><br>node\_config\_disk\_size\_gb - Size of the disk attached to each node, specified<br>in GB. The smallest allowed disk size is 10GB. Defaults to 100GB.<br><br>node\_config\_preemptible - Whether or not the underlying node VMs are<br>preemptible. See the official documentation for more information. Defaults to<br>false. https://cloud.google.com/kubernetes-engine/docs/how-to/preemptible-vms | `list(map(string))` | n/a | yes |
| pod\_security\_policy\_enabled | A PodSecurityPolicy is an admission controller resource you create that<br>validates requests to create and update Pods on your cluster. The<br>PodSecurityPolicy resource defines a set of conditions that Pods must meet to be<br>accepted by the cluster; when a request to create or update a Pod does not meet<br>the conditions in the PodSecurityPolicy, that request is rejected and an error<br>is returned.<br><br>If you enable the PodSecurityPolicy controller without first defining and<br>authorizing any actual policies, no users, controllers, or service accounts can<br>create or update Pods. If you are working with an existing cluster, you should<br>define and authorize policies before enabling the controller.<br><br>https://cloud.google.com/kubernetes-engine/docs/how-to/pod-security-policies | `bool` | `false` | no |
| private\_endpoint | Whether the master's internal IP address is used as the cluster endpoint and the<br>public endpoint is disabled. | `bool` | `false` | no |
| private\_nodes | Whether nodes have internal IP addresses only. If enabled, all nodes are given<br>only RFC 1918 private addresses and communicate with the master via private<br>networking. | `bool` | `true` | no |
| release\_channel | Kubernetes releases updates often, to deliver security updates, fix known<br>issues, and introduce new features. Release channels provide control over how<br>often clusters are automatically updated, and offer customers the ability to<br>balance between stability and functionality of the version deployed in the<br>cluster.<br><br>When you enroll a cluster in a release channel, Google automatically manages the<br>version and upgrade cadence for the cluster and its node pools. All channels<br>offer supported releases of GKE and are considered GA (although individual<br>features may not always be GA, as marked). The Kubernetes releases in these<br>channels are official Kubernetes releases and include both GA and beta<br>Kubernetes APIs (as marked). New Kubernetes versions are first released to the<br>Rapid channel, and over time will be promoted to the Regular, and Stable<br>channel. This allows you to subscribe your cluster to a channel that meets your<br>business, stability, and functionality needs.<br><br>This can be one of 'RAPID', 'REGULAR', or 'STABLE'.<br><br>Setting a release channel overrides the 'min\_master\_version' option.<br><br>https://cloud.google.com/kubernetes-engine/docs/concepts/release-channels | `string` | `"REGULAR"` | no |
| services\_secondary\_range\_name | The name of the secondary range to be used as for the services CIDR block.<br>The secondary range will be used for service ClusterIPs. This must be an<br>existing secondary range associated with the cluster subnetwork. | `string` | n/a | yes |
| stackdriver\_logging | Whether Stackdriver Kubernetes logging is enabled. This should only be set to<br>"false" if another logging solution is set up. | `bool` | `true` | no |
| stackdriver\_monitoring | Whether Stackdriver Kubernetes monitoring is enabled. This should only be set to<br>"false" if another monitoring solution is set up. | `bool` | `true` | no |
| vpc\_network\_name | The name of the Google Compute Engine network to which the cluster is<br>connected. | `string` | n/a | yes |
| vpc\_subnetwork\_name | The name of the Google Compute Engine subnetwork in which the cluster's<br>instances are launched. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| endpoint | Cluster endpoint |
