
terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "1.45.0"
    }
  }
}

variable "hcloud_token" {}
provider "hcloud" {
  token = "${var.hcloud_token}"
}

variable "tailscale_auth_key" {}

variable "env_name" {}

variable "node_image" {
  default = "ubuntu-22.04"
}

variable "server_type" {
  default = "cx11"
}

// possible values nbg1, fsn1, hel1, ash or hil
variable "location" {
  default = "fsn1"
}

variable "ssh_key_name" {}

# domain used for load balancer and certificates
variable "base_domain" {
  default = "example.com"
}