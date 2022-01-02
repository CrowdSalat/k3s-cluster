terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "1.32.2"
    }
  }
}

variable "hcloud_token" {
    type = string
    sensitive = true
}

provider "hcloud" {
  token = var.hcloud_token
}

data "hcloud_ssh_keys" "all_keys" {
}

data "hcloud_locations" "ds" {
}

output "print_locations" {
  value = data.hcloud_locations.ds
}

output "print_server_spec" {
  value = hcloud_server.main
}

resource "hcloud_server" "main" {
  name = "k3s"
  image = "debian-11"
  server_type = "cx21"
  ssh_keys  = [for pub_key in data.hcloud_ssh_keys.all_keys.ssh_keys : pub_key.id]
  location = "nbg1"
}

resource "hcloud_volume" "master" {
  name      = "k3s-volume"
  size      = 10
  server_id = hcloud_server.main.id
  automount = true
  format    = "ext4"
}
