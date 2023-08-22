
data "hcloud_ssh_key" "ssh_key" {
  fingerprint = "${var.ssh_fingerprint}"
}

data "template_file" "cloud_init" {
	template = "${file("cloud-init.yml.tpl")}"

	vars = {
    tailscale_key = "${var.tailscale_api_key}"
	}
}

# debug cloud-init config file
#output "rendered" {
#  value = "${data.template_file.cloud_init.rendered}"
#}

# Allow only incoming ICMP and SSH
resource "hcloud_firewall" "k3s-firewall" {
  name = "k3s-firewall"

  rule {
    direction = "in"
    protocol = "icmp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol = "tcp"
    port = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}

# Create a server
resource "hcloud_server" "k3s" {
  name        = "${var.env_name}-k3s"
  image       = "${var.node_image}"
  server_type = "${var.server_type}"
  ssh_keys = [ data.hcloud_ssh_key.ssh_key.id]

  firewall_ids = [ hcloud_firewall.k3s-firewall.id ]

  user_data = "${data.template_file.cloud_init.rendered}"

  connection {
    type="ssh"
    host = "${hcloud_server.k3s.ipv4_address}"
    agent = true
  }

  provisioner "file" {
    source      = "${path.module}/scripts/install_k3s.sh"
    destination = "/root/install_k3s.sh"
  }  
}
