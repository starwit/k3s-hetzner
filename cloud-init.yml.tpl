#cloud-config
---
apt:
  sources:
    tailscale.list:
      source: deb https://pkgs.tailscale.com/stable/ubuntu focal main
      keyid: 2596A99EAAB33821893C0A79458CA832957F5868

# Update/Upgrade & Reboot if necessary
package_update: true
package_upgrade: true
package_reboot_if_required: true

packages:
  - apt-transport-https
  - ca-certificates
  - curl
  - software-properties-common
  - inetutils-traceroute
  - tmux
  - vim
  - tailscale
runcmd:
  - tailscale up --authkey ${tailscale_key}
  - curl -sfL https://get.k3s.io | sh -s -
