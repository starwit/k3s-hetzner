
terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = ">= 0.14"
    }

    tailscale = {
      source  = "tailscale/tailscale"
      version = ">= 0.13"
    } 

  }
}

variable "hcloud_token" {}
provider "hcloud" {
  token = "${var.hcloud_token}"
}

variable "tailscale_api_key" {}
provider "tailscale" {
  api_key = "${var.tailscale_api_key}"
  tailnet = "starwit.de"
}

variable "env_name" {}

variable "node_image" {
  default = "ubuntu-22.04"
}

variable "server_type" {
  default = "cx11"
}

variable "volume_size" {
  default = 10
}

variable "datacenter" {
  default = "hel1-dc2"
}

variable "ssh_fingerprint" {} //fingerprint of ssh key already present in Hetzner project
variable "ssh_private_key" {}

