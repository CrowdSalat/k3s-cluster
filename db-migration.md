# db migration 

## backup mysql database

```shell

ssh root@78.47.255.193
# dump
date
docker exec kvb-rad-mysql mysqldump -u root --password=krautsalat --opt kvbbike-db > kvbbike-db-mysql.sql
date
# dump comp mode
date
docker exec kvb-rad-mysql mysqldump -u root --password=krautsalat --compatible=ansi --opt kvbbike-db > kvbbike-db-ansi.sql
date

exit

scp -T root@78.47.255.193:"kvbbike-db-mysql.sql kvbbike-db-ansi.sql" ~/Desktop

```

## cockroach db

used free tier of cockroach.

get password for db user [here](https://cockroachlabs.cloud/clusters)


```shell
# Download CA Cert (Required only once)
curl --create-dirs -o $HOME/.postgresql/root.crt -O https://cockroachlabs.cloud/clusters/39bf8cb2-2dfd-4865-99f5-42b6130303e1/cert

# Download the latest CockroachDB Client (v21.2.9)
curl https://binaries.cockroachdb.com/cockroach-v21.2.9.linux-amd64.tgz | tar -xz; sudo cp -i cockroach-v21.2.9.linux-amd64/cockroach /usr/local/bin/

# Connect to your database
cockroach sql --url "postgresql://crowdsalat@free-tier13.aws-eu-central-1.cockroachlabs.cloud:26257/defaultdb?sslmode=verify-full&options=--cluster%3Dcrowdsalat-1065&sslrootcert=$HOME/.postgresql/root.crt"

# or via connection string
postgresql://crowdsalat:REVEAL_PASSWORD@free-tier13.aws-eu-central-1.cockroachlabs.cloud:26257/defaultdb?sslmode=verify-full&options=--cluster%3Dcrowdsalat-1065&sslrootcert=$HOME/.postgresql/root.crt

```

## migrate mysql stuff to cockroach

[mysql to cockroach](https://www.cockroachlabs.com/docs/stable/migrate-from-mysql.html)