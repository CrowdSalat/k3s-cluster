# Server Setup

[argocd](https://argocd.weyrich.dev)

## Infrastructure

Installation of VLS, k3s is described [here](./infrastructure/readme.md).

## Deployment


## DNS

The DNS is created manually and is configured via [cloudflare webui](https://dash.cloudflare.com/login). There is an A and an AAAA entry configured in cloudflare which map the domain name to the vls ipv4 and ipv6 address. You may need to configure a new CNAME for every subdomain you want to use.

## Domain

The domain weyrich.dev is bought on namecheap (14€ a year) and can be managed via the [webui](https://www.namecheap.com/myaccount/login/?ReturnUrl=%2f). To configure namecheap to use the cloudflare DNS follow the [instructions](https://www.namecheap.com/support/knowledgebase/article.aspx/767/10/how-to-change-dns-for-a-domain/).
