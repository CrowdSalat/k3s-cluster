# Infrastructure

## VLS

Terraform is used to create a VLS in Hetzner Cloud and a add set of ssh keys to access the VLS. The used module is documented [here](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs), but you may want to consult [normal API doc](https://docs.hetzner.cloud/#overview) because it is more verbose and allows you to get IDs and other crucial stuff. A new API Key can be created in [Hetzner Cloud console](https://console.hetzner.cloud). Make sure to copy it because it is only showed to you once.

```shell
export API_TOKEN=HETZNER_TOKEN
cd infrastructure
terraform init 
terraform apply -var "hcloud_token=$API_TOKEN"

# to print output
terraform output

# to remove vls
terraform destroy -var "hcloud_token=$API_TOKEN"
```

## k3s

```shell
# install k3s
## https://rancher.com/docs/k3s/latest/en/installation/install-options/#options-for-installation-with-script
curl -sfL https://get.k3s.io | sh -

# get kube config for cluster
cat /etc/rancher/k3s/k3s.yaml
```
