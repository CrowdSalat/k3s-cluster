#!/bin/bash
set -e

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 2. disable tls on argocd server
kubectl patch -n argocd deployment argocd-server --type json -p='[ { "op": "replace", "path":"/spec/template/spec/containers/0/command","value": ["argocd-server","--staticassets","/shared/app","--insecure"] }]' 

# install app of apps
kubectl -n argocd apply -f argocd-bootstrap-app-of-apps.yaml
