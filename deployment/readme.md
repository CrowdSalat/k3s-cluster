# argo-app-of-apps

```shell
helm  -n argocd upgrade --install appsofapp .

helm  -n argocd delete appsofapp
```

## argocd

1. [Install argo](https://argo-cd.readthedocs.io/en/stable/getting_started/#1-install-argo-cd)
2. Disable TLS on argo-server (--insecure) to work with an ingress with tls termination
2. [Configure ingress resource with certmanager](https://argo-cd.readthedocs.io/en/stable/operator-manual/ingress/#ssl-passthrough-with-cert-manager-and-lets-encrypt)

```shell
# 1.
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 2. disable tls on argocd server
kubectl patch -n argocd deployment argocd-server --type json -p='[ { "op": "replace", "path":"/spec/template/spec/containers/0/command","value": ["argocd-server","--staticassets","/shared/app","--insecure"] }]' 

# install app of apps
kubectl -n argocd apply -f argocd-bootstrap-app-of-apps.yaml

#  3. (optional, if added to app-of-apps) configure ingress which uses tls handoff (default behaviour of traefik)
kubectl apply -f ./argo-ingress.yaml

# 4. get password for admin user
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d 

# 5. change password with argocd cli
brew install argocd
kubectl port-forward svc/argocd-server -n argocd 8080:80
argocd login localhost:8080
kubectl -n argocd delete secret argocd-initial-admin-secret
```

### sealedSecrets
s
- [Bitnami sealedSecrets](https://github.com/bitnami-labs/sealed-secrets) allows you to save encrypted secrets in your repository which will get decrypted inside of the k8s cluster.
- It consists of a [kubeseal](https://github.com/bitnami-labs/sealed-secrets#usage) cli and a operator which runs in the cluster. The installation is described [here](https://github.com/bitnami-labs/sealed-secrets/releases)
- check [release notes](https://github.com/bitnami-labs/sealed-secrets/blob/main/RELEASE-NOTES.md) before updating

#### install cli

```shell
# install cli
brew install kubeseal@0.15.0

# (optional) you can download the public cert which is used to encrypt the secrets and use it with the --cert flag
kubeseal \
 --controller-name=sealed-secrets \
 --controller-namespace=kube-system \
 --fetch-cert > sealedSecretCert.pem
```

#### usage examples

- You can create a sealedSecret resource either
  1. by converting a existing secret resource (yaml) to a sealedSecret
  2. by encrypting a string which you can use as a value in a sealedSecret resource (raw mode)
- sealedSecrets support three types of [scopes](https://github.com/bitnami-labs/sealed-secrets#scopes) for encryption:
  1. strict (default) - the secret must be sealed with exactly the same name and namespace.
  2. namespace-wide - you can freely rename the sealed secret within a given namespace.
  3. cluster-wide - the secret can be unsealed in any namespace and can be given any name.

```shell
# creation from secret
kubectl create secret generic secret-name --dry-run=client --from-literal=foo=bar -o yaml | \
kubeseal --controller-name=sealed-secrets --controller-namespace=kube-system \
 --format yaml > mysealedsecret.yaml

# creation of single value in raw mode

## scope strict
echo -n foo | \
  kubeseal --controller-name=sealed-secrets --controller-namespace=kube-system \
  --raw --from-file=/dev/stdin \
  --namespace apps --name strictsecret
 
## namespace-wide
echo -n foo | \
  kubeseal --controller-name=sealed-secrets --controller-namespace=kube-system \
  --raw --from-file=/dev/stdin \
  --namespace apps --scope namespace-wide

## cluster-wide
echo -n foo | \
  kubeseal --controller-name=sealed-secrets --controller-namespace=kube-system \
  --raw --from-file=/dev/stdin \
  --scope namespace-wide
```

### cert-manager (letsencrypt)

- [cert-manager](https://cert-manager.io/) is a k8s native x.509 certificate manager.
- It uses custom resource definitions
  - [Issuer/ClusterIssuer](https://cert-manager.io/docs/concepts/issuer/) represent CAs. A ClusterIssuer works for multiple namespaces. A normal Issuer only for one namespace.
  - [Certificate](https://cert-manager.io/docs/concepts/certificate/) represents the x509 certificates which will be renewed. It will be used to derive a k8s secret.
- It can be used to deploy ACME (Let's Encrypt) certificates.

1. Install it with the [official helm chart](https://artifacthub.io/packages/helm/jetstack/cert-manager)
2. Configure [ACME Issuer with dns challenge for cloudflare](https://cert-manager.io/docs/configuration/acme/dns01/cloudflare/)
3. To automatically deliver a valid certificate to a ingress resource add the annotation `cert-manager.io/cluster-issuer: cloudflare-dns-acme-ca` and set a host with a secret under tls. [Here](https://cert-manager.io/docs/usage/ingress/)) are the complete instructions.

```shell
# 1. configure acme with cloudflare 
kubectl apply --namespace cert-manager -f ./provisioning/ca-acme-dns.yaml 

## the value for api-token in the sealedSecret was create in the following way
### get your api token from https://dash.cloudflare.com/profile/api-tokens
### generate the sealedSecret from the secret
TMP_API_TOKEN=
kubectl create secret generic cloudflare-api-token-secret \
    --namespace cert-manager --from-literal=api-token=$TMP_API_TOKEN \
    --dry-run=client -o yaml | \
  kubeseal --scope=strict --namespace cert-manager \
  --name cloudflare-api-token-secret --format yaml
```
