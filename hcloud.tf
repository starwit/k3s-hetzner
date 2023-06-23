
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

# Create a server
resource "hcloud_server" "k3s" {
  name        = "${var.env_name}-k3s"
  image       = "${var.node_image}"
  server_type = "${var.server_type}"
  ssh_keys = [ data.hcloud_ssh_key.ssh_key.id]

  user_data = "${data.template_file.cloud_init.rendered}"

  provisioner "file" {
    source      = "${path.module}/scripts/bootstrap.sh"
    destination = "/root/bootstrap.sh"
  }

  connection {
    type="ssh"
    host = "${hcloud_server.k3s.ipv4_address}"
    agent = true
  }
}
