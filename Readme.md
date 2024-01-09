# Terraform project to run a K3s server on Hetzner

## How to setup a fully functional k3s, that is reachable via Tailscale

1. Get Hetzner API token for the project you want to deploy the machine in (if not existing, please create one in Hetzner Cloud Console and add it to Bitwarden)
2. Make sure that there is a SSH key in the same Hetzner project that you know the name of and have access to
2. Generate Tailscale auth token
    1. Go to https://login.tailscale.com/admin/settings/keys
    2. Click "Generate auth key"
        1. Enable "pre-approved" 
        2. Enable "tags" and assign tags "k8s" and "ssh-server"
        3. Keep defaults for everything else
3. Create `vars.tfvars` from `vars.tfvars.template` (do not change the template!)
    1. Insert hetzner API token at `hcloud_token`
    2. Adapt `env_name` (+ `server_type` and `location` if needed)
    3. Insert Tailscale auth key at `tailscale_auth_key`
    4. Insert ssh key name from Hetzner console at `ssh_key_name`
4. Run `terraform plan` and if it succeeds run `terraform apply`
    1. Take note of the server ip in the output
5. You should now be able to connect to the machine via ssh using its public IP
6. It takes a couple of minutes for everything to update, the machine to reboot, Tailscale to setup and K3s to install. After that, the following things should work
    1. SSH connection should also be possible through tailscale (Tailscale name is `${env_name}-k3s`)
    2. `curl ${env_name}-k3s` should return `404 page not found`
7. Get Kubernetes config from the cluster
    1. `scp ${env_name}-k3s:/etc/rancher/k3s/k3s.yaml ~/.kube/xyz.yaml`
    2. Change `server: https://127.0.0.1:6443` entry to `server: https://${env_name}-k3s:6443`

## General explanation

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
* tailscale_api_key = "key" - Tailscale auth key, to add VPN to new server (see https://login.tailscale.com/admin/settings/keys; for a fully automated setup, you have to check "pre-approved" when creating the key)
* base_domain = domain used for load balancer and certificates
