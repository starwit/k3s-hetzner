
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

provider "hcloud" {
  token = "${var.hcloud_token}"
}

provider "tailscale" {
  api_key = "${var.tailscale_api_key}"
  tailnet = "starwit.de"
}

variable "hcloud_token" {}

variable "env_name" {}

variable "node_image" {
  default = "ubuntu-22.04"
}

variable "master_type" {
  default = "cx11"
}

variable "ssh_fingerprint" {} //finger print of ssh key already present in Hetzner project
variable "ssh_private_key" {}

variable "tailscale_api_key" {}