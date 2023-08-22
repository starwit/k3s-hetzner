# Terraform project to run a K3s server on Hetzner

This project does:
* update & upgrade
* install and activate tailscale
* install k3s
* setup firewall to allow access via tailscale only

You have to provide the following params:
* hcloud_token = "Hetzner-Token" - lets Terraform talk to Hetzner API
* ssh_private_key = "path/to/ssh/key" - used to login into new servers
* ssh_fingerprint = "fingerprint" - SSH key already present in your Hetzner project to be provisioned to new server
* env_name = "test1" - how your box should be named
* tailscale_api_key = "key" - Tailscale auth key, to add VPN to new server (for a fully automated setup, you have to check "pre-approved" when creating the key)
