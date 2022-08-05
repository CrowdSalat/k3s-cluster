# Cockroach 

You find the db user and generate a password in [Cockroach Webconsole](https://cockroachlabs.cloud/cluster/). 

```shell
# to create sealed secret for kvb-rad user 
export user=kvb-rad
export password=<PASSWORD>

kubectl create secret generic cockroach-user-$user --from-literal=spring.datasource.password=$password -n apps --dry-run=client -o yaml | \
    kubeseal --format yaml > deployment/03_apps/cockroachdb/$user-cockroach-user-sealed.yaml

```
