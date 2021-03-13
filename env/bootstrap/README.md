## Requirements

No requirements.

## Providers

No provider.

## Modules

| Name | Source | Version |
|------|--------|---------|
| gke-cluster | ../../modules/gke |  |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_private\_images | Whether to create the IAM role for storage.objectViewer, required to access<br>GCR for private container images. | `bool` | `false` | no |
| cloud\_nat\_logging\_filter | What filtering should be applied to logs for this NAT. Valid values are:<br>'ERRORS\_ONLY', 'TRANSLATIONS\_ONLY', 'ALL'. Defaults to 'ERRORS\_ONLY'. | `string` | `"ERRORS_ONLY"` | no |
| cluster\_name | The name of the cluster, unique within the project and zone. | `string` | n/a | yes |
| cluster\_secondary\_range\_cidr | n/a | `string` | n/a | yes |
| cluster\_secondary\_range\_name | The name of the secondary range to be used as for the cluster CIDR block.<br>The secondary range will be used for pod IP addresses. This must be an<br>existing secondary range associated with the cluster subnetwork. | `string` | n/a | yes |
| daily\_maintenance\_window\_start\_time | The start time of the 4 hour window for daily maintenance operations RFC3339<br>format HH:MM, where HH : [00-23] and MM : [00-59] GMT. | `string` | n/a | yes |
| enable\_cloud\_nat | Whether to enable Cloud NAT. This can be used to allow private cluster nodes to<br>accesss the internet. Defaults to 'true'. | `bool` | `true` | no |
| enable\_cloud\_nat\_logging | Whether the NAT should export logs. Defaults to 'true'. | `bool` | `true` | no |
| gcp\_location | The location (region or zone) in which the cluster master will be created,<br>as well as the default node location. If you specify a zone (such as<br>us-central1-a), the cluster will be a zonal cluster with a single cluster<br>master. If you specify a region (such as us-west1), the cluster will be a<br>regional cluster with multiple masters spread across zones in that region.<br>Node pools will also be created as regional or zonal, to match the cluster.<br>If a node pool is zonal it will have the specified number of nodes in that<br>zone. If a node pool is regional it will have the specified number of nodes<br>in each zone within that region. For more information see:<br>https://cloud.google.com/kubernetes-engine/docs/concepts/regional-clusters | `string` | n/a | yes |
| gcp\_project\_id | The ID of the project in which the resources belong. | `string` | n/a | yes |
| http\_load\_balancing\_disabled | The status of the HTTP (L7) load balancing controller addon, which makes it<br>easy to set up HTTP load balancers for services in a cluster. It is enabled<br>by default; set disabled = true to disable. | `bool` | `false` | no |
| identity\_namespace | The workload identity namespace to use with this cluster. Currently, the only<br>supported identity namespace is the project's default<br>'[project\_id].svc.id.goog'.<br>https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity | `string` | `""` | no |
| master\_authorized\_networks\_cidr\_blocks | Defines up to 20 external networks that can access Kubernetes master<br>through HTTPS. | `list(map(string))` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "display_name": "default"<br>  }<br>]</pre> | no |
| master\_ipv4\_cidr\_block | The IP range in CIDR notation to use for the hosted master network. This<br>range will be used for assigning internal IP addresses to the master or set<br>of masters, as well as the ILB VIP. This range must not overlap with any<br>other ranges in use within the cluster's network. | `string` | `"172.16.0.0/28"` | no |
| node\_pools | The list of node pool configurations, each can include:<br><br>name - The name of the node pool, which will be suffixed with '-pool'.<br>Defaults to pool number in the Terraform list, starting from 1.<br><br>initial\_node\_count - The initial node count for the pool. Changing this will<br>force recreation of the resource. Defaults to 1.<br><br>autoscaling\_min\_node\_count - Minimum number of nodes in the NodePool. Must be<br>>=0 and <= max\_node\_count. Defaults to 2.<br><br>autoscaling\_max\_node\_count - Maximum number of nodes in the NodePool. Must be<br>>= min\_node\_count. Defaults to 3.<br><br>management\_auto\_repair - Whether the nodes will be automatically repaired.<br>Defaults to 'true'.<br><br>management\_auto\_upgrade - Whether the nodes will be automatically upgraded.<br>Defaults to 'true'.<br><br>version - The Kubernetes version for the nodes in this pool. Note that if this<br>field is set the 'management\_auto\_upgrade' will be overriden and set to 'false'.<br>This is to avoid both options fighting on what the node version should be. While<br>a fuzzy version can be specified, it's recommended that you specify explicit<br>versions as Terraform will see spurious diffs when fuzzy versions are used. See<br>the 'google\_container\_engine\_versions' data source's 'version\_prefix' field to<br>approximate fuzzy versions in a Terraform-compatible way.<br><br>node\_config\_machine\_type - The name of a Google Compute Engine machine type.<br>Defaults to n1-standard-1. To create a custom machine type, value should be<br>set as specified here:<br>https://cloud.google.com/compute/docs/reference/rest/v1/instances#machineType<br><br>node\_config\_disk\_type - Type of the disk attached to each node (e.g.<br>'pd-standard' or 'pd-ssd'). Defaults to 'pd-standard'<br><br>node\_config\_disk\_size\_gb - Size of the disk attached to each node, specified<br>in GB. The smallest allowed disk size is 10GB. Defaults to 100GB.<br><br>node\_config\_preemptible - Whether or not the underlying node VMs are<br>preemptible. See the official documentation for more information. Defaults to<br>false. https://cloud.google.com/kubernetes-engine/docs/how-to/preemptible-vms | `list(map(string))` | n/a | yes |
| node\_pools\_labels | Map of maps containing node labels by node-pool name | `map(map(string))` | <pre>{<br>  "all": {},<br>  "default-node-pool": {}<br>}</pre> | no |
| pod\_security\_policy\_enabled | A PodSecurityPolicy is an admission controller resource you create that<br>validates requests to create and update Pods on your cluster. The<br>PodSecurityPolicy resource defines a set of conditions that Pods must meet to be<br>accepted by the cluster; when a request to create or update a Pod does not meet<br>the conditions in the PodSecurityPolicy, that request is rejected and an error<br>is returned.<br><br>If you enable the PodSecurityPolicy controller without first defining and<br>authorizing any actual policies, no users, controllers, or service accounts can<br>create or update Pods. If you are working with an existing cluster, you should<br>define and authorize policies before enabling the controller.<br><br>https://cloud.google.com/kubernetes-engine/docs/how-to/pod-security-policies | `bool` | `false` | no |
| private\_endpoint | Whether the master's internal IP address is used as the cluster endpoint and the<br>public endpoint is disabled. | `bool` | `false` | no |
| private\_nodes | Whether nodes have internal IP addresses only. If enabled, all nodes are given<br>only RFC 1918 private addresses and communicate with the master via private<br>networking. | `bool` | `true` | no |
| services\_secondary\_range\_cidr | n/a | `string` | n/a | yes |
| services\_secondary\_range\_name | The name of the secondary range to be used as for the services CIDR block.<br>The secondary range will be used for service ClusterIPs. This must be an<br>existing secondary range associated with the cluster subnetwork. | `string` | n/a | yes |
| vpc\_network\_name | The name of the Google Compute Engine network to which the cluster is<br>connected. | `string` | n/a | yes |
| vpc\_subnetwork\_cidr\_range | n/a | `string` | n/a | yes |
| vpc\_subnetwork\_name | The name of the Google Compute Engine subnetwork in which the cluster's<br>instances are launched. | `string` | n/a | yes |

## Outputs

